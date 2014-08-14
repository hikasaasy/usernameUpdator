/**
 * SfdcjOppUpdateControllerのテストクラス
 * @Auther Mitsuhiro Okamoto / mokamoto@salesforce.com
 */
@isTest
private class SfdcjOppUpdateControllerTest{
    
    /**
     * init()とclear()のテスト
     */
    static testMethod void initAndClear() {
        SfdcjOppUpdateController con = new SfdcjOppUpdateController();
       
        con.init();
                
        System.assertNotEquals(null,con.criteria);
        System.assertEquals(false,con.searched);

        con.clear(); 
               
        SfdcjOppUpdateController.OppDto dot = new SfdcjOppUpdateController.OppDto();        
        con.oppList.add(dot);

        con.clear();

        System.assertNotEquals(null,con.criteria);
        System.assertEquals(false,con.searched);
        System.assertEquals(0,con.oppList.size());
        
        
    }

    static testMethod void search() {
        //Todo Test
        SfdcjOppUpdateController con = new SfdcjOppUpdateController();
        con.init();
        con.search();

        //TODO Assert未実装
        
        con.criteria.name__c = 'test';
        con.criteria.startdate__c = Date.today();
        con.criteria.enddate__c = Date.today();
        con.search();
        clearCriteria(con);
        con.cancel();
        
        // ・・・・・・
    }
        
    static testMethod void bulkupdate() {
        //Todo Test
        SfdcjOppUpdateController con = new SfdcjOppUpdateController();
        con.init();
        con.search();
        //TODO Assert未実装               
        con.bulkupdate();        
    }
    
    
    private static void clearCriteria(SfdcjOppUpdateController con){
        con.criteria.name__c = null;
        con.criteria.startdate__c = null;
        con.criteria.enddate__c = null;
    }
    
}