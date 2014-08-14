@isTest
private class UserListExtensionTest {
    private static testMethod void test1(){
        List<User> userList = new List<User>();
        User u1 = new User();
        u1.username = 'test.test@example.hikasaasy.com';
        userList.add(u1);
        User u2 = new User();
        u2.username = 'chatty.test@example.hikasaasy.com';
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(userList);
        UserListExtension ule = new UserListExtension(controller);
        ule.usernameUpdate();
    }

    private static testMethod void test2(){
        Profile p = [select id from profile where name='システム管理者'];
        List<User> userList = new List<User>();
        User u1 = new User();
        u1.username = 'test.test@example.hikasaasy.com';
        u1.lastName = 'user1';
        u1.email = 'user1@test.com';
        u1.alias = 'user1';
        u1.TimeZoneSidKey = 'Asia/Tokyo';
        u1.LocaleSidKey = 'ja_JP';
        u1.EmailEncodingKey = 'ISO-2022-JP';
        u1.ProfileId = p.id;
        u1.LanguageLocaleKey = 'ja';
        userList.add(u1);
        insert userList;        
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(userList);
        UserListExtension ule = new UserListExtension(controller);
        
        ule.usernameUpdate();
    }
/*
    private static testMethod void test3(){
        Profile p = [select id from profile where name='Chatter Free User'];
        List<User> userList = new List<User>();
        User u2 = new User();
        u2.username = 'chatty.test2@example.hikasaasy.com';
        u2.lastName = 'user2';
        u2.email = 'user2@test.com';
        u2.alias = 'user2';
        u2.TimeZoneSidKey = 'Asia/Tokyo';
        u2.LocaleSidKey = 'ja_JP';
        u2.EmailEncodingKey = 'ISO-2022-JP';
        u2.ProfileId = p.id;
        u2.LanguageLocaleKey = 'ja';
        userList.add(u2);
        insert userList;        
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(userList);
        UserListExtension ule = new UserListExtension(controller);
        
        ule.usernameUpdate();
    }
*/    
}