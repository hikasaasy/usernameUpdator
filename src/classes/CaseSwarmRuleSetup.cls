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

public with sharing class CaseSwarmRuleSetup {

    String step1 = null;
    String withStatus = null;
    String withPriority = null;
    String withType = null;
    String followGroup = null;

    public String getStep1() {
        return step1 ;
    }
                    
    public void setStep1(String step1 ) { 
        this.step1 = step1; 
    }

    public List<SelectOption> getStep1Options() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('全てのケース','全てのケース'));
        options.add(new SelectOption('自分が所有しているケース',     '自分が所有しているケース'));
        options.add(new SelectOption('指定する状況のケース',  '指定する状況のケース'));
        options.add(new SelectOption('指定する優先度のケース','指定する優先度のケース'));
        options.add(new SelectOption('指定する種別のケース',      '指定する種別のケース'));
        return options;
    }

    public String getWithStatus() {
        return withStatus;
    }
                    
    public void setWithStatus(String withStatus) { 
        this.withStatus = withStatus; 
    }

    public List<SelectOption> getStatusOptions() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
       return options;
    }

    public String getWithPriority() {
        return withPriority;
    }
                    
    public void setWithPriority(String withPriority) { 
        this.withPriority = withPriority; 
    }

    public List<SelectOption> getPriorityOptions() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Case.Priority.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
       return options;
    }

    public String getWithType() {
        return withType;
    }
                    
    public void setWithType(String withType) { 
        this.withType = withType; 
    }

    public List<SelectOption> getTypeOptions() {
        List<SelectOption> options = new List<SelectOption>();

        Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
       return options;
    }

    public String getFollowGroup() {
        return followGroup;
    }
                    
    public void setFollowGroup(String followGroup) { 
        this.followGroup= followGroup; 
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

    public PageReference action() {
    
        String ruleName = step1;
    
        Case_Swarm_Rule__c rule = new Case_Swarm_Rule__c();
        rule.Type__c = step1 ;
        if (step1.equals('指定する状況のケース')) {
            rule.Case_Status__c = withStatus;
            ruleName = '状況：' + withStatus;
        } else if (step1.equals('指定する優先度のケース')) {
            rule.Case_Priority__c = withPriority;
            ruleName = '優先度：' + withPriority;
        } else if (step1.equals('指定する種別のケース')) {
            rule.Case_Type__c = withType;
            ruleName = 'ケース：' + withType;
        }
        rule.Group_Id__c = followGroup;
        ruleName += ', 公開グループ：' + [select name from Group where type = 'Regular' and Id = :followGroup].name;
        rule.Description__c = ruleName ;
        insert rule;
        
        // Redirect the user back to the original page
        PageReference pageRef = Page.SwarmRuleSaveSuccess;
        pageRef.setRedirect(true);
        return pageRef;
    }
}