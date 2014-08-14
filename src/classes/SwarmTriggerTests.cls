@isTest
private class SwarmTriggerTests {

    static testMethod void testGroups() {
        User user1 = SwarmTestUtility.createTestUser();
        Group group1 = SwarmTestUtility.createGroup('Group'+SwarmTestUtility.createRandomWord());
        SwarmTestUtility.joinGroup(user1, group1);
        
        System.runAs(user1) {
        Case_Swarm_Rule__c csr = new Case_Swarm_Rule__c();
        csr.Case_Type__c = 'One';
        
        //fails when it's not an ID
        csr.Group_Id__c = 'Fail';
        
        try {
        	insert csr;
        	System.assert(False);
        } catch (Exception e) {
        	
        }
        
        //fails when it's a bad ID
        csr.Group_Id__c = 'a00A0000001tXne';
        
        try {
        	insert csr;
        	System.assert(False);
        } catch (Exception e) {
        	
        }   
        
        //succeed when it's a good if
        csr.Group_Id__c = group1.Id;
        
    	insert csr;
        
        //
        Opportunity_Swarm_Rule__c osr = new Opportunity_Swarm_Rule__c();
        osr.Type__c = 'One';
        
        //fails when it's not an ID
        osr.Group_Id__c = 'Fail';
        
        try {
        	insert osr;
        	System.assert(False);
        } catch (Exception e) {
        	
        }
        
        //fails when it's a bad ID
        osr.Group_Id__c = 'a00A0000001tXne';
        
        try {
        	insert osr;
        	System.assert(False);
        } catch (Exception e) {
        	
        }   
        
        //succeed when it's a good if
        osr.Group_Id__c = group1.Id;
        
    	insert osr;
        }
        
    }
}