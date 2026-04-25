@isTest
global class CountryAPIMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        response.setBody(getMockResponseBody());
        return response;
    }
    
    private String getMockResponseBody() {
        // Simulamos una respuesta con 3 países de ejemplo
        List<Map<String, Object>> countries = new List<Map<String, Object>>();
        
        // País 1: España
        Map<String, Object> spain = new Map<String, Object>{
            'name' => 'Spain',
            'alpha2Code' => 'ES',
            'alpha3Code' => 'ESP',
            'capital' => 'Madrid',
            'region' => 'Europe',
            'regionalBlocs' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'acronym' => 'EU',
                    'name' => 'European Union'
                }
            }
        };
        
        // País 2: Japón (sin bloques regionales)
        Map<String, Object> japan = new Map<String, Object>{
            'name' => 'Japan',
            'alpha2Code' => 'JP',
            'alpha3Code' => 'JPN',
            'capital' => 'Tokyo',
            'region' => 'Asia',
            'regionalBlocs' => new List<Map<String, Object>>()
        };
        
        // País 3: México (con múltiples bloques)
        Map<String, Object> mexico = new Map<String, Object>{
            'name' => 'Mexico',
            'alpha2Code' => 'MX',
            'alpha3Code' => 'MEX',
            'capital' => 'Mexico City',
            'region' => 'Americas',
            'regionalBlocs' => new List<Map<String, Object>>{
                new Map<String, Object>{
                    'acronym' => 'NAFTA',
                    'name' => 'North American Free Trade Agreement'
                },
                new Map<String, Object>{
                    'acronym' => 'USMCA',
                    'name' => 'United States-Mexico-Canada Agreement'
                }
            }
        };
        
        countries.add(spain);
        countries.add(japan);
        countries.add(mexico);
        
        return JSON.serialize(countries);
    }
}