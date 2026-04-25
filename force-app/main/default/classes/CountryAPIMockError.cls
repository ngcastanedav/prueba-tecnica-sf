@isTest
global class CountryAPIMockError implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(500);
        response.setBody('{"error": "Internal Server Error"}');
        return response;
    }
}