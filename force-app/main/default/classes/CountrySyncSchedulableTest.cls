@isTest
private class CountrySyncSchedulableTest {
    
    @isTest
    static void testSchedulableExecution() {
        // Configurar el mock
        Test.setMock(HttpCalloutMock.class, new CountryAPIMock());
        
        Test.startTest();
        // Ejecutar el schedulable
        CountrySyncSchedulable schedulable = new CountrySyncSchedulable();
        schedulable.execute(null);
        Test.stopTest();
        
        // Verificar que se crearon los registros
        List<Country__c> countries = [SELECT Id FROM Country__c];
        System.assertEquals(3, countries.size(), 'El schedulable debería sincronizar 3 países');
    }
    
    @isTest
    static void testSchedulableScheduling() {
        // Este test verifica que se puede programar correctamente
        Test.startTest();
        String jobId = System.schedule('Test Country Sync', '0 0 3 * * ?', new CountrySyncSchedulable());
        Test.stopTest();
        
        // Verificar que el job se creó
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger 
                          WHERE Id = :jobId];
        
        System.assertNotEquals(null, ct, 'El job debería haberse creado');
        System.assertEquals('0 0 3 * * ?', ct.CronExpression);
    }
}