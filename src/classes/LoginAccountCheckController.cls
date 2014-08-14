public with sharing virtual class LoginAccountCheckController {
    private String consumer_key;
    private String consumer_secret;

    protected String username;
    private LoginAccount__c la;
    private String instance_url;
    private String access_token;
    private OAuthJSON token_info;
    private OAuthJSON basic;
    private OAuthJSON me;
    private OAuthJSON org;
    private OAuthJSON version;

    public String message {get;private set;}

    protected LoginAccountCheckController() {
    }
    public LoginAccountCheckController(ID id) {
        this();
        init(id);
    }
    public LoginAccountCheckController(ApexPages.StandardController controller) {
        this(controller.getRecord().Id);
    }

    public void init(ID id) {
        List<LoginAccount__c> la_list = [Select UserName__c, Password__c, Server__c, ConfigName__c,
            CompanyName__c, CreatedDate__c, Email__c, Instance__c, LastCheckDate__c, Name__c, OrganizationType__c,
            OrgId__c, OrgName__c, PhotoUrl__c, TrialExpirationDate__c, UserType__c, VersionName__c, Valid__c
            From LoginAccount__c Where Id = :id Limit 1];
        if (la_list.size() == 0) return;
        la = la_list[0];
        clearData();
        consumer_key = config.ConsumerKey__c;
        consumer_secret = config.ConsumerSecret__c;

        try {
            username = la.UserName__c;
            // login test
            Map<String, String> params = getAccessTokenAuthorizationPassword(username, la.Password__c);
            if (params.get('error') != null) throw new OAuthException();
            access_token = params.get('access_token');
            instance_url = params.get('instance_url');
            Pattern instance_url_pattern = pattern.compile('https://(.+)\\.salesforce\\.com'); 
            Matcher m = instance_url_pattern.matcher(instance_url);
            if (m.matches()) {
                la.Instance__c = m.group(1);
            } else {
               instance_url_pattern = pattern.compile('https://(.+\\.database\\.com)'); 
               m = instance_url_pattern.matcher(instance_url);
                if (m.matches()) {
                    la.Instance__c = m.group(1);
                }
            }
            // get basic info
            String basic_url = params.get('id');
            if (basic_url != null) {
                basic = getJson(basic_url);
                if (basic != null && basic.value_type == OAuthJSON.ValueType.HASH_VALUE) {
                    if (basic.get('user_type') != null) {
                        la.UserType__c = basic.get('user_type').string_value;
                    }
                }
            }
            // get my info
            String me_url = instance_url + '/services/data/v29.0/chatter/users/me';
            me = getJson(me_url);
            if (me != null && me.value_type == OAuthJSON.ValueType.HASH_VALUE) {
                if (me.get('name') != null) la.Name__c = me.get('name').string_value;
                if (me.get('email') != null) la.Email__c = me.get('email').string_value;
                if (me.get('companyName') != null) la.CompanyName__c = me.get('companyName').string_value;
            }
            // get org info
            String org_soql = 'Select Id, Name, CreatedDate, OrganizationType, TrialExpirationDate From Organization Limit 1';
            String org_url = instance_url + '/services/data/v29.0/query/?q=' + EncodingUtil.urlEncode(org_soql, 'UTF-8');
            org = getJson(org_url);
            if (org != null && org.value_type == OAuthJSON.ValueType.HASH_VALUE) {
                if (org.get('totalSize') != null && org.get('totalSize').string_value == '1') {
                    OAuthJSON records = org.get('records');
                    if (records.value_type == OAuthJSON.ValueType.ARRAY_VALUE && records.size() == 1) {
                        OAuthJSON record = records.get(0);
                        la.OrgId__c = record.get('Id').string_value;
                        la.OrgName__c = record.get('Name').string_value;
                        la.OrganizationType__c = record.get('OrganizationType').string_value;
                        la.TrialExpirationDate__c = formatDatetime(record.get('TrialExpirationDate').string_value);
                        la.CreatedDate__c = formatDatetimeGmt(record.get('CreatedDate').string_value);
                    }
                }
            } else {
                org_url = instance_url + '/services/data/v29.0/connect/organization';
                org = getJson(org_url);
                if (org != null && org.value_type == OAuthJSON.ValueType.HASH_VALUE) {
                    if (org.get('orgId') != null) la.OrgId__c = org.get('orgId').string_value;
                    if (org.get('name') != null) la.OrgName__c = org.get('name').string_value;
                }
            }
            // get version info
            String version_url = instance_url + '/services/data';
            version = getJson(version_url);
            if (version != null && version.value_type == OAuthJSON.ValueType.ARRAY_VALUE) {
                List<OAuthJSON> versions = version.array_value;
                if (versions.size() > 0) {
                    OAuthJSON v = versions[versions.size() - 1];
                    la.VersionName__c = v.get('label').string_value;
                }
            }
            //VersionName__c

            la.Valid__c = true;
            message = 'Success!';
        } catch (OAuthException e) {
            message = 'OAuth Failed!';
        }
        if (!la.Valid__c) message = 'Failed!';
    }

    private Datetime formatDatetime(String str) {
        if (str == null || str == '') return null;
        return Datetime.valueOfGmt(str.replace('T', ' ').replace('.000+0000', ''));
    }

    private Datetime formatDatetimeGmt(String str) {
        if (str == null || str == '') return null;
        return Datetime.valueOfGmt(str.replace('T', ' ').replace('.000+0000', ''));
    }

    public PageReference updateData() {
        if (la.Valid__c) {
            if (me != null) {
                // delete old img
                List<Attachment> delete_imgs = [Select Id From Attachment Where ParentId = :la.Id];
                // get new img
                String photo_url = basic.get('photos').get('thumbnail').string_value + '?oauth_token=' + EncodingUtil.urlEncode(access_token, 'UTF-8');
                Blob image_data = getImageData(photo_url);
                if (image_data != null) {
                    Attachment img = new Attachment (
                        ParentId = la.Id,
                        Body = image_data,
                        ContentType = 'image/jpg',
                        Name = 'Photo'
                    );
                    insert img;
                    la.PhotoUrl__c = '/servlet/servlet.FileDownload?file=' + img.Id;
                    update la;
                }
                if (delete_imgs.size() > 0) delete delete_imgs;
            }
        }
        // update data
        la.LastCheckDate__c = Datetime.now();
        update la;
        return new PageReference('/' + la.Id);
    }

    private Blob getImageData(String url) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(url);
        HttpResponse res = send(req);
        return getBodyAsBlob(res);
    }

    private Map<String, String> getAccessTokenAuthorizationPassword(String username, String password) {
        String body =
            'grant_type=password' +
            '&client_id=' + EncodingUtil.urlEncode(consumer_key, 'UTF-8') +
            '&client_secret=' + EncodingUtil.urlEncode(consumer_secret, 'UTF-8') +
            '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
            '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        // req.setHeader('X-PrettyPrint', '1');
        req.setMethod('POST');
        req.setEndpoint(la.Server__c + '/services/oauth2/token');
        req.setBody(body);
        HttpResponse res = send(req);
        String res_body = getResponseBody(res, 'getAccessTokenAuthorizationPassword');

        return parseJsonParameters(res_body);
    }

    private OAuthJSON getJson(String url) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Authorization', 'Bearer ' + access_token);
        // req.setHeader('X-PrettyPrint', '1');
        HttpResponse res = send(req);
        String body = getResponseBody(res, 'getJson:' + url);
        OAuthJSON json = null;
        if (/*res.getStatusCode() / 100 == 2 &&*/ body != null && body != '') {
            json = OAuthJSON.newInstance(body);
        } else if (res.getStatusCode() == 301 || res.getStatusCode() == 302) {
            json = getJson(res.getHeader('Location'));
        }
        System.debug('url: ' + url);
        System.debug('json: ' + body);
        return json;
    }

    private void clearData() {
        if (!la.Valid__c) {
            la.CompanyName__c = null;
            la.CreatedDate__c = null;
            la.Email__c = null;
            la.Instance__c = null;
            la.LastCheckDate__c = null;
            la.Name__c = null;
            la.OrganizationType__c = null;
            la.OrgId__c = null;
            la.OrgName__c = null;
            la.PhotoUrl__c = null;
            la.TrialExpirationDate__c = null;
            la.UserType__c = null;
            la.VersionName__c = null;
        }
        la.Valid__c = false;
    }

    protected virtual HttpResponse send(HttpRequest req) {return new Http().send(req);}

    protected virtual String getResponseBody(HttpResponse res, String type) {return res.getBody();}

    protected virtual Blob getBodyAsBlob(HttpResponse res) {return res.getBodyAsBlob();}

    public static Map<String, String> parseJsonParameters(String value) {
        Map<String, String> parameters = null;
        OAuthJSON json = OAuthJSON.newInstance(value);
        if (json.value_type == OAuthJSON.ValueType.HASH_VALUE) {
            parameters = new Map<String, String>();
            for (String key : json.hash_value.keySet()) {
                OAuthJSON val = json.hash_value.get(key);
                if (val.value_type == OAuthJSON.ValueType.STRING_VALUE) {
                    parameters.put(key, val.string_value);
                }
            }
        }
        return parameters;
    }

    public LoginAccountManagerConfig__c config {
        get {
            if (config == null) {
                List<LoginAccountManagerConfig__c> sl = [Select ConsumerKey__c, ConsumerSecret__c From LoginAccountManagerConfig__c Where Name = :la.ConfigName__c];
                if (sl.size() > 0) config = sl[0];
            }
            return config;
        }
        private set;
    }
}