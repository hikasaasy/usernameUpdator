/*
Copyright (c) 2010 salesforce.com, inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, 
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

By: Chris Kemp <ckemp@salesforce.com> and Sandy Jones <sajones@salesforce.com>
*/

public class CaseSwarmTest {

    static List<User> testUsers = new List<User>();

    static User user1 = null;
    static User user2 = null;
    
    static final String groupName = '## Swarm My Test Group##';
    static Id groupId;

    static void buildUp() {
        user1 = SwarmTestUtility.createTestUser();
        user2 = SwarmTestUtility.createTestUser();
        System.runAs (user1) {            
            Group testGroup = SwarmTestUtility.createGroup(groupName);
            groupId =testGroup.id;

            CaseSwarmTest.testUsers.add(user1);
            CaseSwarmTest.testUsers.add(user2);
            
            // Add to group
            SwarmTestUtility.joinGroup(testUsers[0], testGroup);
            SwarmTestUtility.joinGroup(testUsers[1], testGroup);    
        }
    }   

    static void tearDown() {

    }

    static testMethod void testGetOptions() {
        CaseSwarmRuleSetup controller = new CaseSwarmRuleSetup();

        // Check that options are populating
        System.assert(0 < controller.getStep1Options().size());
        System.assert(0 < controller.getStatusOptions().size());
        System.assert(0 < controller.getPriorityOptions().size());
        System.assert(0 < controller.getTypeOptions().size());
        System.assert(0 < controller.getPublicGroups().size());
    }
    
    static testMethod void testAllCases() {

        buildUp();

        System.runAs(user1) {
            PageReference pageRef = Page.CaseSwarmRuleSetup;
            Test.setCurrentPage(pageRef);
          
            CaseSwarmRuleSetup controller = new CaseSwarmRuleSetup();
    
            controller.setStep1('全てのケース');
            System.assertEquals('全てのケース', controller.getStep1());
            controller.setFollowGroup(CaseSwarmTest.groupId);
            System.assertEquals(CaseSwarmTest.groupId, controller.getFollowGroup());
            String nextPage = controller.action().getUrl();
    
            // Verify that the success page displays  
            System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
    
            // Verify a rule was added
            System.assertEquals(1, [select count() from Case_Swarm_Rule__c where CreatedById = :user1.Id]);
            
            // Create a case
            Case testCase = new Case();
            insert testCase;
            // Check that swarm was added
      
            for (User currentUser : testUsers) {
                System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testCase.Id and SubscriberId = :currentUser.Id]);
            }
        }      
        tearDown();
    }
    
    static testMethod void testOnlyAccountsIOwn() {

        buildUp();
        
        System.runAs ( user1 ) {

            PageReference pageRef = Page.CaseSwarmRuleSetup;
            Test.setCurrentPage(pageRef);
          
            CaseSwarmRuleSetup controller = new CaseSwarmRuleSetup();
        
            controller.setStep1('自分が所有しているケース');
            System.assertEquals('自分が所有しているケース', controller.getStep1());
            controller.setFollowGroup(CaseSwarmTest.groupId);
            System.assertEquals(CaseSwarmTest.groupId, controller.getFollowGroup());
            String nextPage = controller.action().getUrl();
        
            // Verify that the success page displays  
            System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
        
            // Verify a rule was added
            System.assertEquals(1, [select count() from Case_Swarm_Rule__c where CreatedById = :user1.id]);
        
            // Create a case with no account (no followers)
            Case testCase = new Case();
            insert testCase;

            for (User currentUser : testUsers) {
                System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testCase.Id and SubscriberId = :currentUser.Id]);
            }
            
            // Create a case with an account
            Account myAccount = new Account();
            myAccount.name = 'Test Account';
            myAccount.ownerId = user1.Id;
            insert myAccount;
        
            Case testCaseWithAccount = new Case();
            testCaseWithAccount.AccountId = myAccount.Id;
            insert testCaseWithAccount;
        
            // Check that swarm was added
            
            for (User currentUser : testUsers) {
                System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testCaseWithAccount.Id and SubscriberId = :currentUser.Id]);
            }
                        
           
        }
        tearDown();
    }

    static testMethod void testStatus() {

        buildUp();
        
        System.runAs(user1) {
        PageReference pageRef = Page.CaseSwarmRuleSetup;
        Test.setCurrentPage(pageRef);
      
        CaseSwarmRuleSetup controller = new CaseSwarmRuleSetup();

        System.assert(0 < controller.getStatusOptions().size());
    
        controller.setStep1('指定する状況のケース');
        System.assertEquals('指定する状況のケース', controller.getStep1());
        controller.setWithStatus('Test Status');
        System.assertEquals('Test Status', controller.getWithStatus());
        controller.setFollowGroup(CaseSwarmTest.groupId);
        System.assertEquals(CaseSwarmTest.groupId, controller.getFollowGroup());
        String nextPage = controller.action().getUrl();
    
        // Verify that the success page displays  
        System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
    
        // Verify a rule was added
        System.assertEquals(1, [select count() from Case_Swarm_Rule__c where CreatedById = :user1.id]);
    
        // Create a case with wrong status (no followers)
        Case testCase = new Case();
        testCase.Status = 'Different Status';
        insert testCase;
        for (User currentUser : testUsers) {
            System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testCase.Id and SubscriberId = :currentUser.Id]);
        }      
        
    
        Case testCaseSuccess = new Case();
        testCaseSuccess.Status = 'Test Status';
        insert testCaseSuccess ;
    
        // Check that swarm was added
        for (User currentUser : testUsers) {
            System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testCaseSuccess.Id and SubscriberId = :currentUser.Id]);
        }        
        

        }
        tearDown();
    }    

    static testMethod void testPriority() {

        buildUp();
        
        System.runAs(user1) {
        PageReference pageRef = Page.CaseSwarmRuleSetup;
        Test.setCurrentPage(pageRef);
      
        CaseSwarmRuleSetup controller = new CaseSwarmRuleSetup();

        System.assert(0 < controller.getStatusOptions().size());
    
        controller.setStep1('指定する優先度のケース');
        System.assertEquals('指定する優先度のケース', controller.getStep1());
        controller.setWithPriority('Test Priority');
        System.assertEquals('Test Priority', controller.getWithPriority());
        controller.setFollowGroup(CaseSwarmTest.groupId);
        System.assertEquals(CaseSwarmTest.groupId, controller.getFollowGroup());
        String nextPage = controller.action().getUrl();
    
        // Verify that the success page displays  
        System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
    
        // Verify a rule was added
        System.assertEquals(1, [select count() from Case_Swarm_Rule__c where CreatedById = :user1.id]);
    
        // Create a case with wrong status (no followers)
        Case testCase = new Case();
        testCase.Priority = 'Different Priority';
        insert testCase;
    
        
        for (User currentUser : testUsers) {
            System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testCase.Id and SubscriberId = :currentUser.Id]);
        }   
    
        Case testCaseSuccess = new Case();
        testCaseSuccess.Priority = 'Test Priority';
        insert testCaseSuccess ;
    
        // Check that swarm was added
        for (User currentUser : testUsers) {
            System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testCaseSuccess.Id and SubscriberId = :currentUser.Id]);
        }           
        

        }
        tearDown();
    }  

    static testMethod void testType() {

        buildUp();
        
        System.assertEquals(0, [select count() from Case_Swarm_Rule__c where createdbyid = :user1.id]);
        
        System.runAs(user1) {
        PageReference pageRef = Page.CaseSwarmRuleSetup;
        Test.setCurrentPage(pageRef);
      
        CaseSwarmRuleSetup controller = new CaseSwarmRuleSetup();

        System.assert(0 < controller.getTypeOptions().size());
    
        controller.setStep1('指定する種別のケース');
        System.assertEquals('指定する種別のケース', controller.getStep1());
        controller.setWithType('Test Type');
        System.assertEquals('Test Type', controller.getWithType());
        controller.setFollowGroup(CaseSwarmTest.groupId);
        System.assertEquals(CaseSwarmTest.groupId, controller.getFollowGroup());
        String nextPage = controller.action().getUrl();
    
        // Verify that the success page displays  
        System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
        
    
        // Verify a rule was added
        System.assertEquals(1, [select count() from Case_Swarm_Rule__c where createdbyid = :user1.id]);
    
        // Create a case with wrong status (no followers)
        Case testCase = new Case();
        testCase.Type = 'Different Type';
        insert testCase;
    
        for (User currentUser : testUsers) {
            System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testCase.Id and SubscriberId = :currentUser.id]);
        }
    
        Case testCaseSuccess = new Case();
        testCaseSuccess.Type= 'Test Type';
        insert testCaseSuccess ;
    
        // Check that swarm was added
        for (User currentUser : testUsers ) {
            System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testCaseSuccess.Id and subscriberId = :currentUser.Id]);
        }
        }
        tearDown();
    }  
}