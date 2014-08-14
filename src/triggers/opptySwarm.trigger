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

trigger opptySwarm on Opportunity (after insert, after update) {

try{
    // Get user and group key prefixes so we can test to see what the UserOrGroupId field contains
    String userType = Schema.SObjectType.User.getKeyPrefix();
    String groupType = Schema.SObjectType.Group.getKeyPrefix();
 
     List<Opportunity_Swarm_Rule__c> swarmRules =  
            [select id, type__c, Opportunity_amount__c, Opportunity_stage__c, Opportunity_type__c, group_id__c, ownerId 
                from Opportunity_Swarm_Rule__c];
 
     List<Id> opptyIds = new List<Id>();
     List<Id> groupIds = new List<Id>();
     Map<Id, Id> groupToOppty = new Map<Id, Id>();

    for (Opportunity thisOppty : Trigger.New) {

        opptyIds.add(thisOppty.id);
        
        for (Opportunity_Swarm_Rule__c rule: swarmRules) {
		
		System.debug('rule.Type__c***********************************'+rule.Type__c);
		
            if (rule.Type__c.equals('全ての商談') ||
                (rule.Type__c.equals('自分が所有している商談') && thisOppty.AccountId != null &&
                    rule.OwnerId == [select ownerId from Account where Id = :thisOppty.AccountId limit 1].ownerId) ||
                (rule.Type__c.equals('指定する金額以上の商談') && 
                    rule.Opportunity_Amount__c <= (thisOppty.Amount)) ||
                (rule.Type__c.equals('指定するフェーズの商談') && 
                    rule.Opportunity_Stage__c.equals(thisOppty.StageName)) ||
                (rule.Type__c.equals('指定する種別の商談') && 
                    rule.Opportunity_Type__c.equals(thisOppty.Type))                
                ) {
                	
                
                // Loop through each user in the public group
                
                
                    groupIds.add(rule.group_id__c);
                
                    groupToOppty.put(rule.group_id__c, thisOppty.id);
                
            }
        }
    }
    
    Set<Id> alreadySubscribed = new Set<Id>();
    for (EntitySubscription es : 
        [select SubscriberId from EntitySubscription where ParentId in :opptyIds]) {
        
        alreadySubscribed.add(es.SubscriberId);
    }

    List<EntitySubscription> newSubscribers = new List<EntitySubscription>();
    
                // Loop through each user in the public group
    for (GroupMember member : 
        [Select Id, UserOrGroupId, GroupId From GroupMember Where GroupId in :groupIds]) {
                
                    // Deal with not adding people who are already following (causes error)
                        
            // If the user or group ID is a user, get user ID to follow
            if (((String)member.UserOrGroupId).startsWith(userType) && 
                !alreadySubscribed.contains(member.UserOrGroupId)) {

                if (((String)member.UserOrGroupId).startsWith(userType) && 
                    !alreadySubscribed.contains(member.UserOrGroupId)) {
            
                    EntitySubscription sub = new EntitySubscription();
                    sub.ParentId = groupToOppty.get(member.groupId);
                    sub.SubscriberId = member.UserOrGroupId;
                    newSubscribers.add(sub);
                }
            }
      }    
                
        
        // If the user or group ID is a user, get user ID to follow

    System.debug('107***********************************'+newSubscribers[0].Id);
    Database.SaveResult[] lsr = Database.insert(newSubscribers, false);
    
    System.debug(lsr);
  }catch(Exception ex){
	System.debug(ex);
  }
}