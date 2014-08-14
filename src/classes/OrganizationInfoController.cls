public class OrganizationInfoController {
    public Organization org{ 
        set; 
        get;
    }
    public OrganizationInfoController(){
        org = [SELECT Name, TrialExpirationDate FROM Organization];
    }
    public PageReference init(){
        try{
            User u = [select OrgExpirationDate__c from User where id=:UserInfo.getUserId()];
            System.debug('u.OrgExpirationDate__c :' + u.OrgExpirationDate__c + '*');
            System.debug('org.TrialExpirationDate:' + org.TrialExpirationDate + '*');
            if(u.OrgExpirationDate__c==null) u.OrgExpirationDate__c = org.TrialExpirationDate;
            update u;
        }catch(Exception e){
            system.debug(e.getStackTraceString());
            //ApexPages.addMessages(new ApexPages.Message(ApexPages.Severity.ERROR, 'コントローラ初期化時のエラー'));
        }
        return null;
    }
    
}