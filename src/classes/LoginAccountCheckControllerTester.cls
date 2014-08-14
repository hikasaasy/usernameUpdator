public class LoginAccountCheckControllerTester extends LoginAccountCheckController {
    public LoginAccountCheckControllerTester(ApexPages.StandardController controller) {
        super(controller);
    }

    protected override HttpResponse send(HttpRequest req) {
        return new HttpResponse();
    }

    protected override String getResponseBody(HttpResponse res, String type) {
        String res_body = '';
        System.debug('getResponseBody: ' + type);
        if (type == 'getAccessTokenAuthorizationPassword') {
            if (username != 'error@test.com') {
                res_body = '{"id":"https://login.salesforce.com/id/00D000000000000000/005000000000000000","issued_at":"1357804724330","instance_url":"https://na1.database.com","signature":"+bDGMXFVlSvaubYvFeFLpHD4GllpcDcrQOmSD5/KCOY=","access_token":"00D100000000000!000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"}';
            } else {
                res_body = '{"error":"error"}';
            }
        } else if (type == 'getJson:https://login.salesforce.com/id/00D000000000000000/005000000000000000') {
            res_body = '{"id":"https://login.salesforce.com/id/00D300000000000000/005300000000000000","asserted_user":true,"user_id":"005300000000000000","organization_id":"00D300000000000000","username":"admin@foo.demo.com","nick_name":"admin","display_name":"admin","email":"admin@foo.demo.com","email_verified":true,"first_name":"test","last_name":"test","timezone":"Asia/Tokyo","photos":{"picture":"https://c.na1.content.force.com/profilephoto/72930000000000/F","thumbnail":"https://c.na1.content.force.com/profilephoto/72930000000000/T"},"addr_street":"1MarketSt","addr_city":"SanFrancisco","addr_state":"CA","addr_country":"US","addr_zip":"94105","mobile_phone":null,"mobile_phone_verified":false,"status":{"created_date":null,"body":null},"urls":{"enterprise":"https://na1.salesforce.com/services/Soap/c/{version}/00D30000000op04","metadata":"https://na1.salesforce.com/services/Soap/m/{version}/00D30000000op04","partner":"https://na1.salesforce.com/services/Soap/u/{version}/00D30000000op04","rest":"https://na1.salesforce.com/services/data/v{version}/","sobjects":"https://na1.salesforce.com/services/data/v{version}/sobjects/","search":"https://na1.salesforce.com/services/data/v{version}/search/","query":"https://na1.salesforce.com/services/data/v{version}/query/","recent":"https://na1.salesforce.com/services/data/v{version}/recent/","profile":"https://na1.salesforce.com/005300000000000000","feeds":"https://na1.salesforce.com/services/data/v{version}/chatter/feeds","groups":"https://na1.salesforce.com/services/data/v{version}/chatter/groups","users":"https://na1.salesforce.com/services/data/v{version}/chatter/users","feed_items":"https://na1.salesforce.com/services/data/v{version}/chatter/feed-items"},"active":true,"user_type":"STANDARD","language":"ja","locale":"ja_JP","utcOffset":32400000,"last_modified_date":"2014-02-24T08:10:37.000+0000","is_app_installed":true}';
        } else if (type == 'getJson:https://na1.database.com/services/data/v26.0/chatter/users/me') {
            res_body = '{"address":{"state":null,"country":null,"street":null,"city":null,"zip":null,"formattedAddress":"  \\n"},"username":"test@demo.jp","email":"test@demo.jp","groupCount":0,"managerId":null,"aboutMe":null,"isActive":true,"chatterActivity":{"commentCount":0,"commentReceivedCount":0,"likeReceivedCount":0,"postCount":0},"chatterInfluence":{"rank":23,"percentile":"0.0"},"followersCount":1,"followingCounts":{"total":6,"records":6,"people":0},"managerName":null,"phoneNumbers":[],"name":"test name","title":null,"userType":"Internal","firstName":"test","lastName":"name","companyName":null,"mySubscription":null,"photo":{"largePhotoUrl":"https://na1.content.force.com/profilephoto/729000000000000/F","photoVersionId":"729000000000000000","smallPhotoUrl":"https://na1.content.force.com/profilephoto/729000000000000/T"},"id":"005000000000000000","url":"/services/data/v26.0/chatter/users/005000000000000000","type":"User"}';
        } else if (type == 'getJson:https://na1.database.com/services/data/v26.0/query/?q=Select+Id%2C+Name%2C+CreatedDate%2C+OrganizationType%2C+TrialExpirationDate+From+Organization+Limit+1') {
            if (username == 'test1@test.com') {
                res_body = '{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Organization","url":"/services/data/v26.0/sobjects/Organization/00D000000000000000"},"Id":"00D000000000000000","Name":"test","CreatedDate":"2013-01-01T00:00:00.000+0000","OrganizationType":"Enterprise Edition","TrialExpirationDate":"2015-12-31T23:59:59.000+0000"}]}';
            } else {
                res_body = '[{"message":"sObject type \'Organization\' is not supported.","errorCode":"INVALID_TYPE"}]';
            }
        } else if (type == 'getJson:https://na1.database.com/services/data/v26.0/connect/organization') {
            res_body = '{"features":{"trendingTopics":true,"chatterActivity":true,"files":true,"chatterGlobalInfluence":true,"chatterMessages":true,"chatterTopics":false,"feedPolling":false,"filesOnComments":true,"viralInvitesAllowed":false,"dashboardComponentSnapshots":true},"userSettings":{"userId":"005000000000000000","canFollow":true,"canOwnGroups":true,"canModifyAllData":false,"canViewAllData":false,"canViewAllUsers":true,"canViewAllGroups":true,"canViewFullUserProfile":true,"canViewPublicFiles":true,"externalUser":false,"hasAccessToInternalOrg":true,"hasFileSync":false,"userLocale":"en_US"},"accessTimeout":0,"name":"test","orgId":"00D000000000000000"}';
        }
        System.debug('res_body: ' + res_body);
        return res_body;
    }

    protected override Blob getBodyAsBlob(HttpResponse res) {
        return EncodingUtil.base64Decode('AAAAALAAAAAABAAEAAAICRAEAOw==');
    }
}