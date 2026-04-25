@isTest
private class LeadTriggerTest {
    
    @TestSetup
    static void setupTestData() {
        List<Country__c> countries = new List<Country__c>();
        
        countries.add(new Country__c(
            Name = 'Spain',
            Alpha2__c = 'ES',
            Alpha3__c = 'ESP',
            Capital__c = 'Madrid',
            Region__c = 'Europe',
            Blocs__c = 'EU',
            BlocsShort__c = 'EU',
            ExternalId__c = 'ES'
        ));
        
        countries.add(new Country__c(
            Name = 'Japan',
            Alpha2__c = 'JP',
            Alpha3__c = 'JPN',
            Capital__c = 'Tokyo',
            Region__c = 'Asia',
            ExternalId__c = 'JP'
        ));
        
        countries.add(new Country__c(
            Name = 'United States',
            Alpha2__c = 'US',
            Alpha3__c = 'USA',
            Capital__c = 'Washington, D.C.',
            Region__c = 'Americas',
            Blocs__c = 'NAFTA, USMCA',
            BlocsShort__c = 'NAFTA, USMCA',
            ExternalId__c = 'US'
        ));
        
        countries.add(new Country__c(
            Name = 'France',
            Alpha2__c = 'FR',
            Alpha3__c = 'FRA',
            Capital__c = 'Paris',
            Region__c = 'Europe',
            Blocs__c = 'EU',
            BlocsShort__c = 'EU',
            ExternalId__c = 'FR'
        ));
        
        insert countries;
    }
    
    /**
     * Test: Insertar Lead con CountryCode = ES (Alpha2)
     */
    @isTest
    static void testLeadInsert_ByCountryCode() {
        Test.startTest();
        Lead lead = new Lead(
            LastName = 'García',
            Company = 'Empresa Test',
            CountryCode = 'ES',
            Country = 'Spain'
        );
        insert lead;
        Test.stopTest();
        
        Lead insertedLead = [SELECT Id, CountryCode, CountryLookup__c, CountryLookup__r.Name,
                                    CountryLookup__r.Alpha2__c, CountryLookup__r.Capital__c
                             FROM Lead 
                             WHERE Id = :lead.Id];
        
        System.assertNotEquals(null, insertedLead.CountryLookup__c, 'El lookup debería estar asignado');
        System.assertEquals('Spain', insertedLead.CountryLookup__r.Name);
        System.assertEquals('ES', insertedLead.CountryLookup__r.Alpha2__c);
        System.assertEquals('Madrid', insertedLead.CountryLookup__r.Capital__c);
    }
    
    /**
     * Test: Insertar Lead con CountryCode = JP (Japón)
     */
    @isTest
    static void testLeadInsert_Japan() {
        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Tanaka',
            Company = 'Tokyo Corp',
            CountryCode = 'JP',
            Country = 'Japan'
        );
        insert lead;
        Test.stopTest();
        
        Lead insertedLead = [SELECT Id, CountryLookup__r.Name, CountryLookup__r.Alpha3__c
                             FROM Lead 
                             WHERE Id = :lead.Id];
        
        System.assertNotEquals(null, insertedLead.CountryLookup__c);
        System.assertEquals('Japan', insertedLead.CountryLookup__r.Name);
        System.assertEquals('JPN', insertedLead.CountryLookup__r.Alpha3__c);
    }
    
    /**
     * Test: Insertar Lead con CountryCode = US
     */
    @isTest
    static void testLeadInsert_UnitedStates() {
        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Smith',
            Company = 'US Company',
            CountryCode = 'US',
            Country = 'United States'
        );
        insert lead;
        Test.stopTest();
        
        Lead insertedLead = [SELECT Id, CountryLookup__r.Name, CountryLookup__r.BlocsShort__c
                             FROM Lead 
                             WHERE Id = :lead.Id];
        
        System.assertNotEquals(null, insertedLead.CountryLookup__c);
        System.assertEquals('United States', insertedLead.CountryLookup__r.Name);
        System.assertEquals('NAFTA, USMCA', insertedLead.CountryLookup__r.BlocsShort__c);
    }
    
    /**
     * Test: Insertar Lead sin país
     */
    @isTest
    static void testLeadInsert_NoCountry() {
        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Test',
            Company = 'Test Company',
            CountryCode = null,
            Country = null
        );
        insert lead;
        Test.stopTest();
        
        Lead insertedLead = [SELECT Id, CountryLookup__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(null, insertedLead.CountryLookup__c, 'Sin país, el lookup debe ser null');
    }
    
    /**
     * Test: Actualizar Lead cambiando CountryCode
     */
    @isTest
    static void testLeadUpdate_ChangeCountry() {
        Lead lead = new Lead(
            LastName = 'García',
            Company = 'Empresa Test',
            CountryCode = 'ES',
            Country = 'Spain'
        );
        insert lead;
        
        Lead beforeUpdate = [SELECT Id, CountryLookup__r.Name FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Spain', beforeUpdate.CountryLookup__r.Name);
        
        Test.startTest();
        lead.CountryCode = 'JP';
        lead.Country = 'Japan';
        update lead;
        Test.stopTest();
        
        Lead afterUpdate = [SELECT Id, CountryLookup__r.Name, CountryLookup__r.Capital__c 
                            FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Japan', afterUpdate.CountryLookup__r.Name);
        System.assertEquals('Tokyo', afterUpdate.CountryLookup__r.Capital__c);
    }
    
    /**
     * Test: Quitar el país (CountryCode = null)
     */
    @isTest
    static void testLeadUpdate_RemoveCountry() {
        Lead lead = new Lead(
            LastName = 'García',
            Company = 'Empresa Test',
            CountryCode = 'ES',
            Country = 'Spain'
        );
        insert lead;
        
        Test.startTest();
        lead.CountryCode = null;
        lead.Country = null;
        update lead;
        Test.stopTest();
        
        Lead afterUpdate = [SELECT Id, CountryLookup__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals(null, afterUpdate.CountryLookup__c, 'Al quitar país, lookup debe ser null');
    }
    
    /**
     * Test: Bulk insert
     */
    @isTest
    static void testLeadInsert_Bulk() {
        List<Lead> leads = new List<Lead>();
        
        leads.add(new Lead(LastName = 'Brown',   Company = 'C1', CountryCode = 'US', Country = 'United States'));
        leads.add(new Lead(LastName = 'García',  Company = 'C2', CountryCode = 'ES', Country = 'Spain'));
        leads.add(new Lead(LastName = 'Moreau',  Company = 'C3', CountryCode = 'FR', Country = 'France'));
        leads.add(new Lead(LastName = 'Tanaka',  Company = 'C4', CountryCode = 'JP', Country = 'Japan'));
        leads.add(new Lead(LastName = 'Unknown', Company = 'C5', CountryCode = null, Country = null));
        
        Test.startTest();
        insert leads;
        Test.stopTest();
        
        List<Lead> insertedLeads = [SELECT Id, LastName, CountryCode, CountryLookup__r.Name 
                                    FROM Lead 
                                    WHERE Id IN :leads 
                                    ORDER BY LastName];
        
        System.assertEquals(5, insertedLeads.size());
        
        System.assertEquals('United States', insertedLeads[0].CountryLookup__r.Name); // Brown
        System.assertEquals('Spain', insertedLeads[1].CountryLookup__r.Name);          // García
        System.assertEquals('France', insertedLeads[2].CountryLookup__r.Name);         // Moreau
        System.assertEquals('Japan', insertedLeads[3].CountryLookup__r.Name);          // Tanaka
        System.assertEquals(null, insertedLeads[4].CountryLookup__c);                  // Unknown
    }
    
    /**
     * Test: País no sincronizado
     */
    @isTest
    static void testLeadInsert_CountryNotInSync() {
        Test.startTest();
        Lead lead = new Lead(
            LastName = 'Smith',
            Company = 'CA Corp',
            CountryCode = 'CA',
            Country = 'Canada'
        );
        insert lead;
        Test.stopTest();
        
        Lead insertedLead = [SELECT Id, CountryCode, CountryLookup__c FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('CA', insertedLead.CountryCode);
        System.assertEquals(null, insertedLead.CountryLookup__c, 
            'País no sincronizado, el lookup debe quedar null');
    }
}