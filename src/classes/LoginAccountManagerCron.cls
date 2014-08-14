global with sharing class LoginAccountManagerCron implements Schedulable {
    public PageReference start() {
        refresh();
        if (results.size() > 0) deleteAll();
        try {
            ID job_id = System.schedule('LoginAccountManagerCron', '0 0 * * * ?', new LoginAccountManagerCron());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success delete jobs.'));
        } catch (System.AsyncException e) {
            ApexPages.addMessages(e);
        } finally {
            refresh();
        }

        return null;
    }

    public List<CronTrigger> results {get;set;}
    public void refresh() {
        results = [SELECT CronExpression, TimesTriggered, NextFireTime FROM CronTrigger Where CronJobDetail.Name = 'LoginAccountManagerCron'];
    }

    global void execute(SchedulableContext ctx) {
        run();
    }

    public void run() {
        Integer maxExecute = 10;
        if (config.MaxExecute__c != NULL) {
            maxExecute = config.MaxExecute__c.intValue();
        }
        List<LoginAccount__c> records = [Select Id, Valid__c From LoginAccount__c Order By LastCheckDate__c NULLS FIRST Limit :maxExecute];
        // execute
        for (LoginAccount__c r : records) {
            executeAsync(r.Id);
        }
        refresh();
    }

    @future(callout=true)
    public static void executeAsync(String id) {
        if(!Test.isRunningTest()) {
            LoginAccountCheckController c = new LoginAccountCheckController(Id);
            c.updateData();
        }
    }

    public void deleteAll() {
        refresh();
        if (results.size() > 0) {
            for (CronTrigger c : results) {
                System.abortJob(c.Id);
            }
            refresh();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Success delete jobs.'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There are no jobs to be deleted.'));
        }
    }

    // config
    public LoginAccountManagerConfig__c config {
        get {
            if (null == config) {
                List<LoginAccountManagerConfig__c> tmp = [Select MaxExecute__c From LoginAccountManagerConfig__c Where Name = 'Core' Limit 1];
                if (tmp.size() > 0) config = tmp[0];
            }
            return config;
        }
        private set;
    }
}