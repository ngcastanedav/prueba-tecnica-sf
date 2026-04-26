public with sharing class CountryAPIService {
    
    private static final String API_KEY = Label.API_KEY;
    private static final String BASE_URL = Label.API_URL;
    
    /**
     * Obtiene todos los países desde la API de countrylayer
     * @return List<CountryAPIResponse> Lista de países
     */
    public static List<CountryAPIResponse> fetchAllCountries() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(BASE_URL + '/all?access_key=' + API_KEY);
        request.setMethod('GET');
        request.setTimeout(120000); // 2 minutos timeout
        
        Http http = new Http();
        HttpResponse response;
        
        try {
            response = http.send(request);
        } catch (CalloutException e) {
            System.debug('Error en la llamada HTTP: ' + e.getMessage());
            throw new CountryAPIException('Error al conectar con la API: ' + e.getMessage());
        }
        
        if (response.getStatusCode() != 200) {
            System.debug('Error HTTP ' + response.getStatusCode() + ': ' + response.getBody());
            throw new CountryAPIException('Error en la API: ' + response.getStatusCode() + ' - ' + response.getBody());
        }
        
        // Deserializar la respuesta JSON
        List<CountryAPIResponse> countries = 
            (List<CountryAPIResponse>) JSON.deserialize(
                response.getBody(), 
                List<CountryAPIResponse>.class
            );
        
        return countries;
    }
    
    /**
     * Sincroniza los países: obtiene de la API y hace upsert en Salesforce
     * @return Integer Número de registros procesados
     */
    public static Integer syncCountries() {
        List<CountryAPIResponse> apiCountries = fetchAllCountries();
        List<Country__c> countriesToUpsert = new List<Country__c>();
        
        for (CountryAPIResponse apiCountry : apiCountries) {
            // Solo procesamos si tiene Alpha2Code (identificador único)
            if (String.isNotBlank(apiCountry.alpha2Code)) {
                countriesToUpsert.add(apiCountry.toCountry());
            }
        }
        
        if (countriesToUpsert.isEmpty()) {
            return 0;
        }
        
        // Usamos Database.upsert con ExternalId__c como campo clave externo
        Database.UpsertResult[] results = Database.upsert(
            countriesToUpsert, 
            Country__c.ExternalId__c, // Campo External ID
            false // allOrNone = false (procesar todos aunque algunos fallen)
        );
        
        // Contar éxitos
        Integer successCount = 0;
        for (Database.UpsertResult result : results) {
            if (result.isSuccess()) {
                successCount++;
            } else {
                for (Database.Error err : result.getErrors()) {
                    System.debug('Error upsert: ' + err.getMessage());
                }
            }
        }
        
        return successCount;
    }
    
    // Excepción personalizada
    public class CountryAPIException extends Exception {}
}