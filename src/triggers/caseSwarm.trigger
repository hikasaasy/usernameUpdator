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

trigger caseSwarm on Case (after insert, after update) {

    // Get user and group key prefixes so we can test to see what the UserOrGroupId field contains
    String userType = Schema.SObjectType.User.getKeyPrefix();
    String groupType = Schema.SObjectType.Group.getKeyPrefix();

    List<Case_Swarm_Rule__c> caseRules = [select id, type__c, case_status__c, case_priority__c, case_type__c, group_id__c, ownerId 
                from Case_Swarm_Rule__c];
    
    List<Id> groupIds = new List<Id>();
    
    List<Id> caseIds = new List<Id>();
    
    Map<Id, Id> groupToCase = new Map<Id, Id>();
    

    
    for (Case thisCase : Trigger.New) {
    
        caseIds.add(thisCase.id);
        
        //RSC not bulkified
        for (Case_Swarm_Rule__c rule: caseRules) {

            if (rule.Type__c.equals('全てのケース') ||
                (rule.Type__c.equals('自分が所有しているケース') && thisCase.AccountId != null &&
                    rule.OwnerId == [select ownerId from Account where Id = :thisCase.AccountId limit 1].ownerId) ||
                (rule.Type__c.equals('指定する状況のケース') && 
                    rule.Case_Status__c.equals(thisCase.Status)) ||
                (rule.Type__c.equals('指定する優先度のケース') && 
                    rule.Case_Priority__c.equals(thisCase.Priority)) ||
                (rule.Type__c.equals('指定する種別のケース') && 
                    rule.Case_Type__c.equals(thisCase.Type))                
                ) {
                
                // Loop through each user in the public group
                groupIds.add(rule.group_id__c);
                groupToCase.put(rule.group_id__c, thisCase.id);
                            
            }
        }
    }

    Set<Id> alreadySubscribed = new Set<Id>();
    for (EntitySubscription es : 
        [select SubscriberId from EntitySubscription where ParentId in :caseIds]) {
        
        alreadySubscribed.add(es.SubscriberId);
    }

    List<EntitySubscription> newSubscribers = new List<EntitySubscription>();

        
    for (GroupMember member : 
        [Select Id, UserOrGroupId, GroupId From GroupMember Where GroupId in :groupIds]) {

        
        
        // If the user or group ID is a user, get user ID to follow
        if (((String)member.UserOrGroupId).startsWith(userType) && 
            !alreadySubscribed.contains(member.UserOrGroupId)) {
    
            EntitySubscription sub = new EntitySubscription();
            sub.ParentId = groupToCase.get(member.groupId);
            sub.SubscriberId = member.UserOrGroupId;
            newSubscribers.add(sub);
        }
    

        
    }

        Database.SaveResult[] lsr = Database.insert(newSubscribers, false);
        
        System.debug(lsr);
}