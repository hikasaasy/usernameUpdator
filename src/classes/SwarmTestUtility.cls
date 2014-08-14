/*
reid.carlberg@salesforce.com
creates entities required for testing.
tests triggers
*/
public with sharing class SwarmTestUtility {

    /*
        A random user is useful for testing in order to be 
        sure that you are able to see data across posts regardless
        of follow status.
    */
    public static User createTestUser() {
        Profile p = [Select Id, Name from Profile where Name = 'システム管理者'];
        return SwarmTestUtility.createTestUser(p);
    }
    
    public static User createTestUser(Profile p) {
        
        String namePrefix = createRandomWord();
        
        AggregateResult[] userCount = [Select count(id) userCount From user where username like :namePrefix];
        
        Object users = userCount[0].get('userCount');
        
        User testUser = new User();
        testUser.Email = 'test@test.com';
        testUser.Username = namePrefix+users+'@testuser.com';

        testUser.LastName = 'test';
        testUser.Alias = 'test';
        testUser.ProfileId = p.Id;
        testUser.LanguageLocaleKey = 'ja';
        testUser.LocaleSidKey = 'ja_JP';
        testUser.TimeZoneSidKey = 'Asia/Tokyo';
        testUser.EmailEncodingKey = 'ISO-2022-JP';
        insert testUser;
        return testUser;
    }

    public static Group createGroup(String name) {
        Group testGroup = new Group();
            testGroup.name = name;
            testGroup.type = 'Regular';
            insert testGroup;
            
            return testGroup;
    }
    
    public static GroupMember joinGroup(User u, Group g) {
        
            GroupMember member1 = new GroupMember();
            member1.GroupId = g.Id;
            member1.UserOrGroupId = u.Id;
            insert member1;
            return member1;
        
    }
    
    /*
        Random words are required for testing 
        as you will likely run into any word I can insert
        during a test class and produce false test results.
    */
        
    public static String createRandomWord() {
        
        String ret = 'word' + math.rint(math.random() * 100000);
        
        return ret;
        
    }
    
    //TEST METHODS
    
    static TestMethod void testRandomWord() {
        
        System.assert(SwarmTestUtility.createRandomWord() != SwarmTestUtility.createRandomWord());
    }
    
    static TestMethod void testCreateUser() {
        
        User u = SwarmTestUtility.createTestUser();
        
        System.assert(u.id != null);
        
    }
    
    static TestMethod void testCreateGroup() {
        
        Group g = SwarmTestUtility.createGroup('name'+SwarmTestUtility.createRandomWord());
        
        System.assert(g.id != null);
    }

    static TestMethod void testJoinGroup() {
        
        Group g = SwarmTestUtility.createGroup('name'+SwarmTestUtility.createRandomWord());
        
        User u = SwarmTestUtility.createTestUser();
        
        GroupMember gm = SwarmTestUtility.joinGroup(u, g);
        
        System.assert(gm.id != null);
        
    }
    

    
}