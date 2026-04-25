@isTest
private class CountryAPIServiceTest {
    
    /**
     * Test: Verificar que fetchAllCountries devuelve datos correctamente
     */
    @isTest
    static void testFetchAllCountries() {
        // Configurar el mock
        Test.setMock(HttpCalloutMock.class, new CountryAPIMock());
        
        Test.startTest();
        List<CountryAPIResponse> countries = CountryAPIService.fetchAllCountries();
        Test.stopTest();
        
        // Verificaciones
        System.assertNotEquals(null, countries, 'La lista no debería ser null');
        System.assertEquals(3, countries.size(), 'Deberían devolverse 3 países');
        
        // Verificar España
        System.assertEquals('Spain', countries[0].name);
        System.assertEquals('ES', countries[0].alpha2Code);
        System.assertEquals('ESP', countries[0].alpha3Code);
        System.assertEquals('Madrid', countries[0].capital);
        System.assertEquals('Europe', countries[0].region);
        System.assertEquals(1, countries[0].regionalBlocs.size());
        System.assertEquals('EU', countries[0].regionalBlocs[0].acronym);
        
        // Verificar método getBlocAcronyms
        System.assertEquals('EU', countries[0].getBlocAcronyms());
        System.assertEquals(null, countries[1].getBlocAcronyms()); // Japón sin bloques
        System.assertEquals('NAFTA, USMCA', countries[2].getBlocAcronyms()); // México con 2 bloques
    }
    
    /**
     * Test: Verificar que syncCountries hace upsert correctamente
     */
    @isTest
    static void testSyncCountries() {
        // Configurar el mock
        Test.setMock(HttpCalloutMock.class, new CountryAPIMock());
        
        Test.startTest();
        Integer result = CountryAPIService.syncCountries();
        Test.stopTest();
        
        // Verificar que devuelve el número correcto
        System.assertEquals(3, result, 'Deberían sincronizarse 3 países');
        
        // Verificar que los registros se crearon en la base de datos
        List<Country__c> countries = [SELECT Id, Name, Alpha2__c, Alpha3__c, Capital__c, Region__c, Blocs__c, ExternalId__c 
                                      FROM Country__c 
                                      ORDER BY Name];
        
        System.assertEquals(3, countries.size(), 'Debería haber 3 registros en Country__c');
        
        // Japón (posición 0 alfabéticamente: J)
        System.assertEquals('Japan', countries[0].Name);
        System.assertEquals('JP', countries[0].Alpha2__c);
        System.assertEquals('JPN', countries[0].Alpha3__c);
        System.assertEquals('Tokyo', countries[0].Capital__c);
        System.assertEquals('Asia', countries[0].Region__c);
        System.assertEquals(null, countries[0].Blocs__c);
        System.assertEquals('JP', countries[0].ExternalId__c);
        
        // México (posición 1 alfabéticamente: M)
        System.assertEquals('Mexico', countries[1].Name);
        System.assertEquals('MX', countries[1].Alpha2__c);
        System.assertEquals('MEX', countries[1].Alpha3__c);
        System.assertEquals('Mexico City', countries[1].Capital__c);
        System.assertEquals('Americas', countries[1].Region__c);
        System.assertEquals('NAFTA, USMCA', countries[1].Blocs__c);
        System.assertEquals('MX', countries[1].ExternalId__c);
        
        // España (posición 2 alfabéticamente: S)
        System.assertEquals('Spain', countries[2].Name);
        System.assertEquals('ES', countries[2].Alpha2__c);
        System.assertEquals('ESP', countries[2].Alpha3__c);
        System.assertEquals('Madrid', countries[2].Capital__c);
        System.assertEquals('Europe', countries[2].Region__c);
        System.assertEquals('EU', countries[2].Blocs__c);
        System.assertEquals('ES', countries[2].ExternalId__c);
    }
    
    /**
     * Test: Verificar actualización de registros existentes (upsert)
     */
    @isTest
    static void testSyncCountries_Update() {
        // Insertamos un registro previo con datos desactualizados
        Country__c existingCountry = new Country__c(
            Name = 'Spain',
            Alpha2__c = 'ES',
            Alpha3__c = 'ESP',
            Capital__c = 'Barcelona', // Dato incorrecto a propósito
            Region__c = 'Europe',
            ExternalId__c = 'ES'
        );
        insert existingCountry;
        
        // Configurar el mock (tiene Madrid como capital)
        Test.setMock(HttpCalloutMock.class, new CountryAPIMock());
        
        Test.startTest();
        CountryAPIService.syncCountries();
        Test.stopTest();
        
        // Verificar que se actualizó (solo debe haber 1 registro de España)
        List<Country__c> spainRecords = [SELECT Id, Capital__c FROM Country__c WHERE ExternalId__c = 'ES'];
        System.assertEquals(1, spainRecords.size(), 'Debería seguir habiendo solo 1 registro de España');
        System.assertEquals('Madrid', spainRecords[0].Capital__c, 'La capital debería haberse actualizado a Madrid');
    }
    
    /**
     * Test: Verificar que el método lanza excepción con error de API
     */
    @isTest
    static void testFetchAllCountries_Error() {
        // Configurar el mock de error
        Test.setMock(HttpCalloutMock.class, new CountryAPIMockError());
        
        Test.startTest();
        try {
            CountryAPIService.fetchAllCountries();
            System.assert(false, 'Debería haber lanzado una excepción');
        } catch (CountryAPIService.CountryAPIException e) {
            // Verificar que el mensaje contiene el código de error
            System.assert(e.getMessage().contains('500'), 'El mensaje debería contener el código 500');
        }
        Test.stopTest();
    }
    
    /**
     * Test: Verificar el método toCountry del wrapper
     */
    @isTest
    static void testWrapperToCountry() {
        CountryAPIResponse wrapper = new CountryAPIResponse();
        wrapper.name = 'France';
        wrapper.alpha2Code = 'FR';
        wrapper.alpha3Code = 'FRA';
        wrapper.capital = 'Paris';
        wrapper.region = 'Europe';
        wrapper.regionalBlocs = new List<CountryAPIResponse.RegionalBloc>();
        
        CountryAPIResponse.RegionalBloc bloc = new CountryAPIResponse.RegionalBloc();
        bloc.acronym = 'EU';
        bloc.name = 'European Union';
        wrapper.regionalBlocs.add(bloc);
        
        Country__c country = wrapper.toCountry();
        
        System.assertEquals('France', country.Name);
        System.assertEquals('FR', country.Alpha2__c);
        System.assertEquals('FRA', country.Alpha3__c);
        System.assertEquals('Paris', country.Capital__c);
        System.assertEquals('Europe', country.Region__c);
        System.assertEquals('EU', country.Blocs__c);
        System.assertEquals('FR', country.ExternalId__c);
    }
    
    /**
     * Test: Wrapper con alpha2Code nulo no debería incluirse
     */
    @isTest
    static void testWrapper_NullAlpha2() {
        // Creamos un mock que devuelve un país sin alpha2Code
        // (Usamos el mock normal pero verificamos la lógica de filtrado en syncCountries)
        
        // Este test verifica que el método toCountry asigna ExternalId__c = alpha2Code
        CountryAPIResponse wrapper = new CountryAPIResponse();
        wrapper.name = 'TestCountry';
        wrapper.alpha2Code = null;
        wrapper.alpha3Code = 'TST';
        wrapper.capital = 'TestCity';
        wrapper.region = 'TestRegion';
        wrapper.regionalBlocs = new List<CountryAPIResponse.RegionalBloc>();
        
        Country__c country = wrapper.toCountry();
        
        System.assertEquals(null, country.ExternalId__c, 'ExternalId debería ser null si alpha2Code es null');
    }
}