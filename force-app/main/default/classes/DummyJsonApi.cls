public with sharing class DummyJsonApi {

    private static final String BASE_URL = 'https://dummyjson.com';
    private static final String USERNAME = 'emilys';
    private static final String PASSWORD = 'emilyspass';

    /**
     * Logs in to DummyJSON and returns the auth token.
     */
    public static String login() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/auth/login');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String,Object>{
            'username' => USERNAME,
            'password' => PASSWORD,
            'expiresInMins' => 30
        }));
        Http http = new Http();
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200){
            Map<String,Object> parsed = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            return (String)parsed.get('accessToken');
        } else {
            throw new CalloutException('Login failed: ' + res.getBody());
        }
    }

    /**
     * Gets all categories.
     */
    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getCategoryOptions() {
        String token = login();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/products/categories');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200){
            List<Object> rawList = (List<Object>)JSON.deserializeUntyped(res.getBody());

            List<PicklistOption> options = new List<PicklistOption>();
            for(Object o : rawList){
                Map<String,Object> item = (Map<String,Object>)o;
                options.add(new PicklistOption(
                    (String)item.get('name'),
                    (String)item.get('slug')
                ));
            }
            return options;
        } else {
            throw new CalloutException('Failed to get categories: ' + res.getBody());
        }
    }

    public class PicklistOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public PicklistOption(String label, String value){
            this.label = label;
            this.value = value;
        }
    }


    /**
     * Gets products by category or all.
     */
    public static List<Map<String,Object>> getProducts(String token, String category) {
        String url = BASE_URL + '/products';
        if(String.isNotBlank(category)){
            url = BASE_URL + '/products/category/' + EncodingUtil.urlEncode(category, 'UTF-8');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200){
            // Deserialize response as Map
            Map<String,Object> parsed = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            // Get the products array
            List<Object> rawProducts = (List<Object>)parsed.get('products');

            // Convert each item to Map<String,Object>
            List<Map<String,Object>> result = new List<Map<String,Object>>();
            for(Object o : rawProducts){
                result.add((Map<String,Object>)o);
            }
            return result;
        } else {
            throw new CalloutException('Failed to get products: ' + res.getBody());
        }
    }
}