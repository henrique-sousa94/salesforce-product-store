public with sharing class DummyJsonAuthService {

    // Store token in a custom setting or custom metadata in real scenario
    private static String authToken;

    /**
     * Logs in to DummyJSON API using username and password,
     * retrieves the authentication token.
     * @return the token string if successful
     */
    @AuraEnabled
    public static String login(String username, String password) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://dummyjson.com/auth/login');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Create JSON payload with user credentials
        String payload = JSON.serialize(new Map<String, Object>{
            'username' => 'emilys',
            'password' => 'emilyspass'
        });
        req.setBody(payload);

        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            // Parse JSON response to extract token
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            authToken = (String) result.get('token');
            return authToken;
        } else {
            throw new AuraHandledException('Login failed with status ' + res.getStatusCode());
        }
    }

    /**
     * Returns stored token if available
     */
    public static String getAuthToken() {
        return authToken;
    }
}