@isTest
private class LoginAccountManagerSetupControllerTest {
    static void init() {
        LoginAccountManagerConfig__c config = new LoginAccountManagerConfig__c(
            Name = 'Core',
            ConsumerKey__c = 'test',
            ConsumerSecret__c = 'test'
        );
        insert config;
    }

    static testMethod void newTest() {
        Test.startTest();
        LoginAccountManagerSetupController t = new LoginAccountManagerSetupController();
        t.config.ConsumerKey__c = 'test';
        t.config.ConsumerSecret__c = 'test';
        t.save();
        Test.stopTest();
    }

    static testMethod void updateTest1() {
        init();
        Test.startTest();
        LoginAccountManagerSetupController t = new LoginAccountManagerSetupController();
        t.config.ConsumerKey__c = 'test';
        t.config.ConsumerSecret__c = 'test';
        t.save();
        Test.stopTest();
    }

    static testMethod void errorTest1() {
        init();
        Test.startTest();
        LoginAccountManagerSetupController t = new LoginAccountManagerSetupController();
        t.config.ConsumerKey__c = 'test';
        t.config.ConsumerSecret__c = NULL;
        t.save();
        Test.stopTest();
    }

    static testMethod void updateTest2() {
        init();
        Test.startTest();
        LoginAccountManagerSetupController t = new LoginAccountManagerSetupController();
        t.config_pre.ConsumerKey__c = 'test';
        t.config_pre.ConsumerSecret__c = 'test';
        t.save();
        Test.stopTest();
    }

    static testMethod void errorTest2() {
        init();
        Test.startTest();
        LoginAccountManagerSetupController t = new LoginAccountManagerSetupController();
        t.config_pre.ConsumerKey__c = 'test';
        t.save();
        t.config_pre.Name = null;
        t.config_pre.ConsumerSecret__c = 'test';
        t.save();
        Test.stopTest();
    }
}