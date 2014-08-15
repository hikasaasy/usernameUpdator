public class OrganizationInfoController {
    private String PREFIX = '組織有効期限アラート(';
    private String SUFFIX = '日前)';
    public boolean testFlag=false;
    public integer alertBefore{get; set;}
    public integer alertOptionsSize{
        get{
            return alertOptions.size();
        }
    }
    public List<SelectOption> alertOptions{
        get{
            Set<String> oSet = new Set<String>();
            for(CronTrigger c : crons){
                String x = c.CronJobDetail.name.substringAfter(PREFIX).substringBefore(SUFFIX);
                oSet.add(x);
            }
            
            alertOptions = new List<SelectOption>();
            String[] oList = new String[]{'1', '3', '5', '10', '15', '20', '25', '30'};
                for(String o : oList){
                    if(!oSet.contains(o))
                        alertOptions.add(new SelectOption(o, o));                        
                }
            return alertOptions;
        }
        private set;
    }
    public Organization org{ 
        get{
            if(org==null){
                return [SELECT Name, TrialExpirationDate, CreatedByID FROM Organization];
            }
            return org;
        }
        
    }
    public User user{ 
        get{
            if(user==null){
                return [SELECT Name, Username, Email from User where id = :org.CreatedById];
            }
            return user;
        }
    }
    public integer cronsSize{
        get{
            return crons.size();
        }
    }
    public List<CronTrigger> crons{
        get{
            return [SELECT Id, CronJobDetail.name, CronJobDetailId, NextFireTime, CreatedDate 
                    FROM CronTrigger
                    WHERE CronJobDetail.name like :(PREFIX+'%')
                    OR CronJobDetail.name like :('%'+SUFFIX)
                    order by nextfiretime 
                   ];        
        }
    }
    public Datetime notificationDate{get; set;}
    
    public OrganizationInfoController(){
        Datetime expDate = org.TrialExpirationDate;
        
        if(testFlag){
            expDate = system.now()+100;
            addInfo('テストメソッド用フラグが設定されています。');
        }
        
        if(expDate == null){
            addInfo('Developer Editionには有効期限がないため、通知設定の必要はありません。');
        }else{
            if(alertOptionsSize==0){
                addInfo('通知ジョブは' + cronsSize + '件登録済みです。');
            }
            /*
            else{
                addInfo('[通知登録] ボタンでアラート登録を行います。');
                addInfo('組織の有効期限(' + expDate.format('yyyy/MM/dd hh:mm:ss') + ')前に通知を行います。');
            }
			*/
        }
    }
    
    public PageReference regist(){
        try{
            if(testFlag){
                notificationDate = system.now()+100;
                addInfo('テストメソッド用フラグが設定されています。');
            }else{
                notificationDate = org.TrialExpirationDate - alertBefore;
            }
            System.schedule(PREFIX + alertBefore + SUFFIX, 
                            notificationDate.format('0 0 9 d M ? yyyy'),
                            new OrgExpireNotificationSchedule());
            addInfo('有効期限の' + alertBefore + '日前でジョブを登録しました。');
        }catch(Exception e){
            system.debug(e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'スケジュール設定時のエラー'));
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    private void addInfo(String m){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, m));
    }
}