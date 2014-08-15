// System.schedule('組織有効期限アラート', '0 21 10 15 8 ?', new OrgExpireNotificationSchedule());

global class OrgExpireNotificationSchedule implements Schedulable {
    global void execute(SchedulableContext sc){
        try{
	        Organization org = [SELECT Name, TrialExpirationDate, CreatedByID FROM Organization];
            User user = [SELECT Name, Username, Email from User where id = :org.CreatedById];
            sendEmail(user.name,  user.Email, user.username, org.Id, org.TrialExpirationDate);
        }catch(Exception e){
			System.debug('エラー：' + e.getMessage());            
			System.debug(e.getStackTraceString());            
        }
    }
    global void sendEmail(String name, String toAddress, String username, String orgId, Datetime expirationDate) {
        String toEmail = toAddress;
        String subject = '研修組織（' + username + '）の有効期限が近付いています';
        String body = '';
        body += name + ' 様';
        body += '\n研修組織の有効期限が近付きました。\n';
        body += '\n有効期限：' + expirationDate;
        body += '\n\n対象組織ID：' + orgId;
        body += '\n管理者ユーザ：' + username;
        body += '\n';
        body += '\n有効期限が過ぎる前に必要なデータ、メタデータがあればご対応ください。';
        body += '\n\n Salesforce University';
        
        Messaging.SingleEmailMessage emailOut = new Messaging.SingleEmailMessage(); 
        emailOut.setSubject(subject);
        List<String> toAddresses = new List<String>();
        toAddresses.add(toEmail);
        emailOut.setToAddresses(toAddresses);
        emailOut.setPlainTextBody(body);
        Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailOut});
    }    
}