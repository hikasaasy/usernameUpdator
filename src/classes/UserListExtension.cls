public class UserListExtension {
    public boolean updated{set; get;}
    private OrgSettings__c settings;
    public userListExtension(ApexPages.StandardSetController controller) {
        // ユーザ名の@よりも左側に.が付くユーザは変更対象
        Integer count = [select count() from User where username like '%.%@%' and IsActive=true];
        if(count==0){   // 変更対象がない
            updated=true;
        }else{
            updated=false;
        }
        if(!updated){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, '[ユーザ名の更新] で更新します。') );
        }
    }

    // 一括変更を行う
    public PageReference usernameUpdate(){
        List<User> uList = [select username from user where isActive=true];
        List<User> updates = new List<User>();

        // 一番多いドメイン名をchattyのドメインにしたい
        Map<String, Integer> domainMap = new Map<String, Integer>();
        for(User u : uList){
            String domain = u.username.substringAfter('@');
            if(domain.equals('chatter.salesforce.com')){
                continue;
            }
            if(domainMap.containsKey(domain)){
                domainMap.put(domain, domainMap.get(domain)+1);
            }else{
                domainMap.put(domain, 1);
            }
        }
        String myDomain=null;
        Integer max=0;
        for(String d : domainMap.keySet()){
            integer i = domainMap.get(d);
            if(max<i){
                max=i;
                myDomain = d;
            }
        }

        // ユーザ名の更新処理
        for(User u : uList){
            String beforeAt = u.username.substringBefore('@');
            String afterAt = u.username.substringAfter('@');
            if(beforeAt.contains('.')){
                if( beforeAt.startsWith('chatty') ){
                    u.username = beforeAt.substringBefore('.') + '@' + myDomain;
                }else{
                    u.username = beforeAt.substringBefore('.') + '@' + afterAt;
                }
                updates.add(u);
            }
        }
        update updates;
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'ユーザ名を更新しました') );
        
        // ユーザ名を変更したユーザのパスワードをpassword123に変更する
        for(User u : updates){
            System.setPassword(u.id, 'password123');
        }
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'パスワードを変更しました') );
        
        // 同じページを再度表示（リダイレクト）
        PageReference ret = Page.UserList;
        ret.setRedirect(true);
        
        return ret;
    }
        
}