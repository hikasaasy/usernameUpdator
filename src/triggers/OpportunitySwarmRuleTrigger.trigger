trigger OpportunitySwarmRuleTrigger on Opportunity_Swarm_Rule__c (before insert, before update) {

    Set<Id> csrIds = new Set<Id>();
    Map<Id, Opportunity_Swarm_Rule__c> groupIdMap = new Map<Id, Opportunity_Swarm_Rule__c>();
    
    //make sure everything is an ID
    for (Opportunity_Swarm_Rule__c csr : Trigger.new) {
        try { 
            Id temp = csr.group_id__c;
            csrIds.add(temp);
            groupIdMap.put(temp, csr);
        } catch (Exception e) {
            csr.group_id__c.addError('Not a valid ID: ' + csr.group_id__c);
        }
    }
    
    //pull all groups with those ids
    List<Group> groups = [Select Id, Name from Group where id in :csrIds];
    
    //make sure we found everything in the set
    if (groups.size() != csrIds.size()) {
        for (Group currentGroup:groups) {
            csrIds.remove(currentGroup.id);
        }  
        for (Id currentId:csrIds) {
            groupIdMap.get(currentId).Group_Id__c.addError('Invalid group id');
        }
    }
    
}