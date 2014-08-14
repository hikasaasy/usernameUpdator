/**
 * 商談一括更新コントローラ<br />
 * 商談一括更新の際の検索、更新処理を提供します。
 *
 * @Auther Mitsuhiro Okamoto / mokamoto@salesforce.com
 */
public with sharing class SfdcjOppUpdateController {

    /**自身が所有するデータを表す定数*/
    private static final String OWNER_OWN = 'own';

    /**すべてのユーザーが所有するデータを表す定数*/
    private static final String OWNER_ALL = 'all';

    /**
     * VisaulforceとApex間の受け渡し用Dtoクラス
     * 検索結果が更新対象かを保持するcheckedと商談オブジェクトを内包しています。 
     */
    public class OppDTO{
        public Boolean checked{get;set;}
        public Opportunity opp{get;set;}
        
        public OppDTO(){
            checked = false;
            opp = new Opportunity();
        }
    }

    /** フェーズ選択リスト値 */
    public List<SelectOption> stageNames{get;set;}

    /** フェーズ選択リスト値 */
    public List<String> selectedStage{get;set;}

    /** 所有者選択リスト値 */
    public List<SelectOption> ownerTypes{get;set;}

    /** ソート対象リスト値 */
    public List<SelectOption> sortFields{get;set;}

    /** ソート順序リスト値 */
    public List<SelectOption> sortOrders{get;set;}


    /** 検索条件が格納されます */
    public SfdcjOppupdateCriteria__c criteria{get;set;}

    /** Dtoクラスのリスト */
    public List<OppDTO> opplist{get;set;}

    /** 検索処理済みかを表すフラグ */
    public Boolean searched{get;set;}

    /** 
     * 初期処理<br />
     * 画面描画時に呼び出されます。各パラメータを初期化し、更新完了後だった場合には、更新対象となったデータを再度検索し、確認の為画面に表示します。
     */
    public void init(){
        //OwerType
        ownerTypes = new List<SelectOption>();
        ownerTypes.add(new SelectOption(OWNER_OWN,'私の商談'));
        ownerTypes.add(new SelectOption(OWNER_ALL,'すべての商談'));

        //Stage
        stageNames = new List<SelectOption>();
        List <Schema.PicklistEntry> stageNameEntries= Schema.SObjectType.Opportunity.fields.StageName.getPicklistValues();
        for(Schema.PicklistEntry stageNameEntry : stageNameEntries){
            if(stageNameEntry.isActive()){
                stageNames.add(new SelectOption(stageNameEntry.getvalue(), stageNameEntry.getLabel()));
            }
        }
        selectedStage = new List<String>();

        //Sort
        sortFields = new List<SelectOption>();
        Map <String, Schema.SObjectField> sortFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        Set<String> sortFieldKeySet = sortFieldMap.keySet();
        sortFields.add(new SelectOption('' , '-- 指定無し --'));
        for(String sortFieldKey : sortFieldKeySet){
           sortFields.add(new SelectOption(sortFieldKey, sortFieldMap.get(sortFieldKey).getDescribe().getLabel()));
        }
        //SortOrder
        sortOrders = new List<SelectOption>();
        sortOrders.add(new SelectOption('ASC','昇順'));
        sortOrders.add(new SelectOption('DESC','降順'));


        if(searched == true){
            search();
        }else{
            criteria = new SfdcjOppupdateCriteria__c();
        }
        searched = false;
    }

    /** 
     * 一括更新処理処理<br />
     * Dtoクラスのリストから、更新チェックの付いたもののみを抽出し、データベースへ反映させます。
     */
    public PageReference bulkUpdate() {

        List<Opportunity> updateOppList = new List<Opportunity>();
        for(oppDto dto : opplist){
            if(dto.checked){
                updateOppList.add(dto.opp);
            }
        }
        if(updateOppList.size() > 0){
            update updateOppList;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, updateOppList.size() + '件のデータの処理が完了しました。'));
        return null;
    }
    
    public PageReference clear(){
        searched = false;
        criteria = new SfdcjOppupdateCriteria__c();
        selectedStage = new List<String>();
        oppList = new List<OppDto>();
        
        return null;
    }

    public PageReference cancel(){
        search();
        return null;
    }


    public PageReference search() {
      searched = true;
      
      List<Opportunity> searchResult = new List<Opportunity>();
      oppList = new List<OppDto>();

    
      //現在Dynamic SOQL内でのへ変数バインドは有効化されていません。有効化後はSOQLインジェクション対策に適用予定
      Map<String,Schema.SObjectField> fieldMap = Opportunity.sObjectType.getDescribe().fields.getMap();
      List<Schema.SObjectField> fieldList = fieldMap.values();
      String selectFields ='';
      for(Integer i =0; i< fieldList.size();i++){
          Schema.SObjectField field = fieldList.get(i);
          if(i==0){
              selectFields += field.getDescribe().getName() + ' ';
          }else{
              selectFields += ', ' + field.getDescribe().getName();         
          }
      }
      
      String query='SELECT ' + selectFields + ' FROM Opportunity';
      String joinString = ' WHERE ';

      if(criteria.name__c != null && criteria.name__c != ''){
          String likeName = '%' + String.escapeSingleQuotes(criteria.name__c) + '%';
          query  += joinString + ' name LIKE \'' + likeName + '\'';
          joinString = ' AND ';
      }
      if(selectedStage.size() > 0){
          String tempStageQuery = '';
          query  += joinString + ' (';

          String tempStageJoinString = '';
          for(String stageName : selectedStage){
              tempStageQuery += tempStageJoinString + ' stageName = \'' + String.escapeSingleQuotes(stageName) +'\'';
              tempStageJoinString = ' OR ';
          }
          tempStageQuery += ') ';
          
          query  += tempStageQuery;
          joinString = ' AND ';
      }
      if(criteria.startDate__c != null){
          query  += joinString + ' closeDate >= ' + String.valueOf(criteria.startDate__c).replace('/','-');
          joinString = ' AND ';
      } 
      if(criteria.endDate__c != null){
          query  += joinString + ' closeDate <= ' + String.valueOf(criteria.endDate__c).replace('/','-');
          joinString = ' AND ';
      }
      if(criteria.opportunitiesOwner__c == OWNER_OWN){
          query += joinString + ' ownerId = \'' + UserInfo.getUserId() +'\'';
          joinString = ' AND ';
      }
      
      //Order
      if(criteria.sort__c != null && criteria.sort__c != ''){
          query  += ' ORDER BY ' + String.escapeSingleQuotes(criteria.sort__c) + ' ' + String.escapeSingleQuotes(criteria.sortOrder__c) + ' NULLS LAST ';
      }

      //Query Limit
      query += ' LIMIT 200';
      searchResult = database.query(query);

      if(searchResult.size() >= 200){
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '検索条件で得られる結果が200件を超えています。200件目以降は表示されません。'));
      }

      for(Opportunity opp : searchResult){
          OppDto temp = new OppDto();
          temp.opp = opp;
          oppList.add(temp);
      }    

      return null;
    }
}