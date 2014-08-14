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

public with sharing class OpptySwarmRuleSetup {

    public String step1 {get;set;}
    public String withStage {get;set;}
    public String withType {get;set;}
    public String followGroup {get;set;}
    public Opportunity_Swarm_Rule__c inputform {get;set;}
    private PageReference pageRef = ApexPages.currentPage();

    public List<SelectOption> getStageOptions() {
        List<SelectOption> options = new List<SelectOption>();

        for( OpportunityStage stage: [select MasterLabel from OpportunityStage where IsActive = true order by SortOrder]) {
            options.add(new SelectOption(stage.MasterLabel, stage.MasterLabel));
        }
       return options;
    }

    public List<SelectOption> getTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Opportunity.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
       return options;
    }

    public List<SelectOption> getPublicGroups() {
        List<SelectOption> options = new List<SelectOption>();

        for (Group thisGroup: [select id, name from Group where type = 'Regular' order by name]) {
            if (thisGroup.Name != null) {
                options.add(new SelectOption(thisGroup.Id, thisGroup.Name));
            }
        }

        if (1 > options.size()) {
            options.add(new SelectOption('', 'エラー：公開グループが設定されていません。設定->ユーザの管理->公開グループ から設定してください。'));
        }
        return options;
    }
    
    public OpptySwarmRuleSetup(){
        inputform = new Opportunity_Swarm_Rule__c();
        step1 = '全ての商談';
    }

    public PageReference saveOpptySwarmRule() {
        String ruleName = step1;
        Opportunity_Swarm_Rule__c rule = new Opportunity_Swarm_Rule__c();
        rule.Type__c = step1 ;
        try {
            if (step1.equals('指定する金額以上の商談')) {
                rule.Opportunity_Amount__c = inputform.Opportunity_Amount__c;
                ruleName = '金額：' + inputform.Opportunity_Amount__c+' 以上';
            } else if (step1.equals('指定するフェーズの商談')) {
                rule.Opportunity_Stage__c = withStage;
                ruleName = 'フェーズ：' + withStage;
            } else if (step1.equals('指定する種別の商談')) {
                rule.Opportunity_Type__c = withType;
                ruleName = '種別：' + withType;
            }
            rule.Group_Id__c = followGroup;
            ruleName += ', 公開グループ：' + [select name from Group where type = 'Regular' and Id = :followGroup].name;
            rule.Description__c = ruleName;
            insert rule;
            
            // Redirect the user back to the original page
            PageReference pageRef = Page.SwarmRuleSaveSuccess;
            pageRef.setRedirect(true);
            return pageRef;
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
    }
}