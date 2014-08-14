public with sharing class LoginAccountManagerSetupController {
    private static final String CONFIG_NAME_CORE = 'Core';
    private static final String CONFIG_NAME_PRE = 'Pre';

    private LoginAccountManagerConfig__c getConfigByName(String name) {
        List<LoginAccountManagerConfig__c> sl = [
            Select Name, ConsumerKey__c, ConsumerSecret__c From LoginAccountManagerConfig__c Where Name = :name
        ];
        if (sl.size() > 0) return sl[0];
        return new LoginAccountManagerConfig__c(Name = name);
    }

    public LoginAccountManagerConfig__c config {
        get {
            if (config == null) {
                config = getConfigByName(CONFIG_NAME_CORE);
            }
            return config;
        }
        set;
    }

    public LoginAccountManagerConfig__c config_pre {
        get {
            if (config_pre  == null) {
                config_pre = getConfigByName(CONFIG_NAME_PRE);
            }
            return config_pre;
        }
        set;
    }

    public void save() {
        try {
            upsert config;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success "' + config.Name + '" config.'));
        } catch (DmlException e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Don\'t save "' + config.Name + '" config.'));
        }
        if (config_pre.ConsumerKey__c != null && config_pre.ConsumerSecret__c != null) {
            try {
                upsert config_pre;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success "' + config_pre.Name + '" config.'));
            } catch (DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Don\'t save "' + config_pre.Name + '" config.'));
            }
        } else if (config_pre.ConsumerKey__c != null || config_pre.ConsumerSecret__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Don\'t save "' + config_pre.Name + '" config.'));
        }
    }
}