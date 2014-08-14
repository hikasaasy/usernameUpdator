@isTest
private class LoginAccountCheckControllerTest {
    static LoginAccount__c init(String username) {
        LoginAccountManagerConfig__c config = new LoginAccountManagerConfig__c(
            Name = 'Core',
            ConsumerKey__c = 'test',
            ConsumerSecret__c = 'test'
        );
        insert config;

        LoginAccount__c la = new LoginAccount__c(
            Name = 'test',
            UserName__c = username,
            Password__c = 'test'
        );
        insert la;
        return la;
    }

    static testMethod void test1Test() {
        LoginAccount__c la = init('test1@test.com');

        Test.startTest();
        LoginAccountCheckControllerTester tester = new LoginAccountCheckControllerTester(
            new ApexPages.StandardController([Select Id, UserName__c From LoginAccount__c Where Id = :la.Id])
        );
        tester.updateData();
        Test.stopTest();
    }

    static testMethod void test2Test() {
        LoginAccount__c la = init('test2@test.com');

        Test.startTest();
        LoginAccountCheckControllerTester tester = new LoginAccountCheckControllerTester(
            new ApexPages.StandardController([Select Id, UserName__c From LoginAccount__c Where Id = :la.Id])
        );
        tester.updateData();
        Test.stopTest();
    }

    static testMethod void errorTest() {
        LoginAccount__c la = init('error@test.com');

        Test.startTest();
        LoginAccountCheckControllerTester tester = new LoginAccountCheckControllerTester(
            new ApexPages.StandardController([Select Id, UserName__c From LoginAccount__c Where Id = :la.Id])
        );
        tester.updateData();
        Test.stopTest();
    }

	static testMethod void cronTest() {
        LoginAccount__c la = init('test1@test.com');

        Test.startTest();
        LoginAccountManagerCron t = new LoginAccountManagerCron();
        t.start();
        t.execute(NULL);
        t.deleteAll();
    }
}