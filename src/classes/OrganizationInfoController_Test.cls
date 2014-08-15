@isTest
public class OrganizationInfoController_Test {
    public static testMethod void test1(){
		OrganizationInfoController c = new OrganizationInfoController();
        c.testFlag=true;
        c.alertBefore=1;
		c.regist();
    }
    public static testMethod void test2(){
		OrganizationInfoController c = new OrganizationInfoController();
        c.testFlag=true;
        c.alertBefore=1;
		c.regist();
        
        List<SelectOption> options = c.alertOptions;
        Organization org = c.org;
        User user = c.user;
    }
}