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

public class OpportunitySwarmTest {

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
            groupId = testGroup.Id;

            OpportunitySwarmTest.testUsers.add(user1);
            OpportunitySwarmTest.testUsers.add(user2);
            
            // Add to group
            SwarmTestUtility.joinGroup(testUsers[0], testGroup);
            SwarmTestUtility.joinGroup(testUsers[1], testGroup);
    
        }
    }   

    static void tearDown() {

    }

    static testMethod void testGetOptions() {
        OpptySwarmRuleSetup controller = new OpptySwarmRuleSetup();

        // Check that options are populating
        System.assert(0 < controller.getStageOptions().size());
        System.assert(0 < controller.getTypeOptions().size());
        System.assert(0 < controller.getPublicGroups().size());
    }

    static testMethod void testAllOpportunities() {

        buildUp();
        System.runAs ( user1 ) {
            PageReference pageRef = Page.OpptySwarmRuleSetup;
            Test.setCurrentPage(pageRef);
          
            OpptySwarmRuleSetup controller = new OpptySwarmRuleSetup();
    
            controller.step1 = '全ての商談';
            System.assertEquals('全ての商談', controller.step1);
            controller.followGroup = OpportunitySwarmTest.groupId;
            controller.followGroup = OpportunitySwarmTest.groupId;
            System.assertEquals(OpportunitySwarmTest.groupId, controller.followGroup);
            String nextPage = controller.saveOpptySwarmRule().getUrl();
    
            // Verify that the success page displays  
            System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
    
            // Verify a rule was added
            System.assertEquals(1, [select count() from Opportunity_Swarm_Rule__c where CreatedById = :user1.Id]);
            
            // Create an oppty
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Swarm Test Opp';
            testOpportunity.StageName = 'Different Stage';
            testOpportunity.CloseDate = Date.newInstance(2010, 03, 26);
            testOpportunity.Amount = 555;
            insert testOpportunity;
            
            // Check that swarm was added -- note that for test resiliance you need to cycle through the group
            for (User currentUser : testUsers) {
                System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :currentUser.Id]);
            }
        }
        tearDown();
    }
    
    static testMethod void testOnlyAccountsIOwn() {

        buildUp();
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        //RSC
        //System.runAs ( thisUser ) {
        System.runAs ( user1 ) {

            PageReference pageRef = Page.OpptySwarmRuleSetup;
            Test.setCurrentPage(pageRef);
          
            OpptySwarmRuleSetup controller = new OpptySwarmRuleSetup();
        
            controller.step1 = '自分が所有している商談';
            System.assertEquals('自分が所有している商談', controller.step1);
            controller.followGroup = OpportunitySwarmTest.groupId;
            System.assertEquals(OpportunitySwarmTest.groupId, controller.followGroup);
            String nextPage = controller.saveOpptySwarmRule().getUrl();
        
            // Verify that the success page displays  
            System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
        
            // Verify a rule was added
            System.assertEquals(1, [select count() from Opportunity_Swarm_Rule__c where CreatedById = :user1.id]);
        
       
            // Create an oppty with no account (no followers)
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Swarm Test Opp';
            testOpportunity.StageName = 'Different Stage';
            testOpportunity.CloseDate = Date.newInstance(2010, 03, 26);
            testOpportunity.Amount = 555;
            insert testOpportunity;
            
            //the owner show created it will follow it
            System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :user1.Id]);
            for (User currentUser : testUsers) {
                if (currentUser.Id != user1.Id) {
                    System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :currentUser.Id]);
                }
            }
        
            // Create an Opportunity with an account
            Account myAccount = new Account();
            myAccount.name = 'Test Account';
            myAccount.ownerId = user1.Id;
            insert myAccount;
        
            Opportunity testOpportunityWithAccount = new Opportunity();
            testOpportunityWithAccount.AccountId = myAccount.Id;
            testOpportunityWithAccount.Name = 'Swarm Failed Test Opp';
            testOpportunityWithAccount.StageName = 'Different Stage';
            testOpportunityWithAccount.CloseDate = Date.newInstance(2010, 03, 26);
            testOpportunityWithAccount.Amount = 555;
            insert testOpportunityWithAccount;
        
            // Check that swarm was added
            for (User currentUser : testUsers) {
                System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testOpportunityWithAccount.Id and SubscriberId = :currentUser.Id]);
            }
        }
        tearDown();
    }

    static testMethod void testAmount() {

        buildUp();
        System.runAs ( user1 ) {
            PageReference pageRef = Page.OpptySwarmRuleSetup;
            Test.setCurrentPage(pageRef);
          
            OpptySwarmRuleSetup controller = new OpptySwarmRuleSetup();
    
            controller.step1 = '指定する金額以上の商談';
            System.assertEquals('指定する金額以上の商談', controller.step1);
            controller.inputform.Opportunity_Amount__c = 50000;
            System.assertEquals(50000, controller.inputform.Opportunity_Amount__c);
            controller.followGroup = OpportunitySwarmTest.groupId;
            System.assertEquals(OpportunitySwarmTest.groupId, controller.followGroup);
            String nextPage = controller.saveOpptySwarmRule().getUrl();
        
            // Verify that the success page displays  
            System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
        
            // Verify a rule was added
            System.assertEquals(1, [select count() from Opportunity_Swarm_Rule__c where CreatedById = :user1.Id]);
        
            // Create an Opportunity with wrong status (no followers)
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Amount = 1;
            testOpportunity.Name = 'Swarm Failed Test Opp';
            testOpportunity.StageName = 'Different Stage';
            testOpportunity.CloseDate = Date.newInstance(2010, 03, 26);
            insert testOpportunity;
        
            //users should not be included.
            for (User currentUser : testUsers) {
                System.debug('SampleId ' + currentUser.id + ', '+ user1.Id);
                if (currentUser.Id != user1.Id) {
                    System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :currentUser.Id]);
                }
            }    
        
            Opportunity testOpportunitySuccess = new Opportunity();
            testOpportunitySuccess.Amount = 50000;
            testOpportunitySuccess.Name = 'Swarm Test Opp';
            testOpportunitySuccess.StageName = 'Different Stage';
            testOpportunitySuccess.CloseDate = Date.newInstance(2010, 03, 26);
            insert testOpportunitySuccess ;
        
    
            for (User currentUser : testUsers) {
                System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testOpportunitySuccess.Id and SubscriberId = :currentUser.Id]);
            }  
                    
        }
        tearDown();
    }    

    static testMethod void testStage() {

        buildUp();
        
        System.runAs ( user1 ) {
        
            PageReference pageRef = Page.OpptySwarmRuleSetup;
            Test.setCurrentPage(pageRef);
          
            OpptySwarmRuleSetup controller = new OpptySwarmRuleSetup();
    
            System.assert(0 < controller.getStageOptions().size());
        
            controller.step1 = '指定するフェーズの商談';
            System.assertEquals('指定するフェーズの商談', controller.step1);
            controller.WithStage = 'Test Stage';
            System.assertEquals('Test Stage', controller.WithStage);
            controller.followGroup = OpportunitySwarmTest.groupId;
            System.assertEquals(OpportunitySwarmTest.groupId, controller.followGroup);
            String nextPage = controller.saveOpptySwarmRule().getUrl();
        
            // Verify that the success page displays  
            System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
        
            // Verify a rule was added
            System.assertEquals(1, [select count() from Opportunity_Swarm_Rule__c where CreatedById = :user1.Id]);
        
            // Create an Opportunity with wrong status (no followers)
            Opportunity testOpportunity = new Opportunity();
            testOpportunity.Name = 'Swarm Failed Test Opp';
            testOpportunity.StageName = 'Different Stage';
            testOpportunity.CloseDate = Date.newInstance(2010, 03, 26);
            testOpportunity.Amount = 555;
            insert testOpportunity;
        
            System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :user1.Id]);
            for (User currentUser : testUsers) {
                if (currentUser.Id != user1.Id) {
                    System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :currentUser.Id]);
                }
            }
            
        
            Opportunity testOpportunitySuccess = new Opportunity();
            testOpportunitySuccess.Name = 'Swarm Test Opp';
            testOpportunitySuccess.StageName = 'Test Stage';
            testOpportunitySuccess.CloseDate = Date.newInstance(2010, 03, 26);
            testOpportunitySuccess.Amount = 555;
            insert testOpportunitySuccess ;
        
            // Check that swarm was added
            for (User currentUser : testUsers) {
                System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testOpportunitySuccess.Id and SubscriberId = :currentUser.Id]);
            }  
        }
        tearDown();
    }  

    static testMethod void testType() {

        buildUp();
        
        System.runAs ( user1 ) {
            
        PageReference pageRef = Page.OpptySwarmRuleSetup;
        Test.setCurrentPage(pageRef);
      
        OpptySwarmRuleSetup controller = new OpptySwarmRuleSetup();

        System.assert(0 < controller.getTypeOptions().size());
    
        controller.step1 = '指定する種別の商談';
        System.assertEquals('指定する種別の商談', controller.step1);
        controller.WithType = 'Test Type';
        System.assertEquals('Test Type', controller.WithType);
        controller.followGroup = OpportunitySwarmTest.groupId;
        System.assertEquals(OpportunitySwarmTest.groupId, controller.followGroup);
        String nextPage = controller.saveOpptySwarmRule().getUrl();
    
        // Verify that the success page displays  
        System.assertEquals('/apex/swarmrulesavesuccess', nextPage);
    
        // Verify a rule was added
        System.assertEquals(1, [select count() from Opportunity_Swarm_Rule__c where CreatedById = :user1.Id]);
    
        // Create an Opportunity with wrong status (no followers)
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Type = 'Different Type';
        testOpportunity.Name = 'Swarm Failed Test Opp';
        testOpportunity.StageName = 'Different Stage';
        testOpportunity.CloseDate = Date.newInstance(2010, 03, 26);
        testOpportunity.Amount = 555;
        insert testOpportunity;
        
        System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :user1.Id]);
        for (User currentUser : testUsers) {
            if (currentUser.Id != user1.Id) {
                System.assertEquals(0, [select count() from EntitySubscription where ParentId = :testOpportunity.Id and SubscriberId = :currentUser.Id]);
            }
        } 
    
        Opportunity testOpportunitySuccess = new Opportunity();
        testOpportunitySuccess.Type= 'Test Type';
        testOpportunitySuccess.Name = 'Swarm Test Opp';
        testOpportunitySuccess.StageName = 'Different Stage';
        testOpportunitySuccess.CloseDate = Date.newInstance(2010, 03, 26);
        testOpportunitySuccess.Amount = 555;
        insert testOpportunitySuccess ;
        
        // Check that swarm was added -- need at least two subscribers (might have more);
        for (User currentUser : testUsers) {
            System.assertEquals(1, [select count() from EntitySubscription where ParentId = :testOpportunitySuccess.Id and SubscriberId = :currentUser.Id]);
        }          
    
        }
        tearDown();
    }  
}