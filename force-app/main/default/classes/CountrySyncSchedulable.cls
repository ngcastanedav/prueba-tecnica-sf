global class CountrySyncSchedulable implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        try {
            Integer processed = CountryAPIService.syncCountries();
            System.debug('CountrySyncSchedulable: Procesados ' + processed + ' países.');
        } catch (Exception e) {
            System.debug('CountrySyncSchedulable ERROR: ' + e.getMessage());
            // Opcional: enviar email de error al admin
        }
    }
}