public with sharing class LeadTriggerHandler {
    
    private static Boolean isExecuting = false;
    
    public static void populateCountryLookup(List<Lead> leads, Map<Id, Lead> oldMap) {
        
        if (isExecuting) {
            return;
        }
        isExecuting = true;
        
        try {
            Set<String> countriesToFind = new Set<String>();
            
            for (Lead lead : leads) {
                String lookupKey = null;
                
                // CountryCode tiene prioridad sobre Country
                if (String.isNotBlank(lead.CountryCode)) {
                    lookupKey = lead.CountryCode.trim();
                } else if (String.isNotBlank(lead.Country)) {
                    lookupKey = lead.Country.trim();
                }
                
                if (lookupKey != null) {
                    countriesToFind.add(lookupKey);
                } else {
                    // Ambos vacíos o CountryCode es null → limpiar lookup
                    lead.CountryLookup__c = null;
                }
            }
            
            // ══════════════════════════════════════════════
            // LIMPIEZA EXTRA: Si CountryCode es null, Country debe ignorarse
            // porque --None-- deja CountryCode=null pero Country con valor residual
            // ══════════════════════════════════════════════
            for (Lead lead : leads) {
                if (String.isBlank(lead.CountryCode) && String.isNotBlank(lead.Country)) {
                    // CountryCode es null → el usuario quitó el país
                    lead.CountryLookup__c = null;
                    countriesToFind.remove(lead.Country.trim());
                }
            }
            
            if (countriesToFind.isEmpty()) {
                return;
            }
            
            Map<String, Id> countryMap = new Map<String, Id>();
            
            for (Country__c c : [
                SELECT Id, Name, Alpha2__c, Alpha3__c
                FROM Country__c
                WHERE Alpha2__c IN :countriesToFind 
                   OR Alpha3__c IN :countriesToFind 
                   OR Name IN :countriesToFind
            ]) {
                if (String.isNotBlank(c.Alpha2__c)) countryMap.put(c.Alpha2__c.toLowerCase(), c.Id);
                if (String.isNotBlank(c.Alpha3__c)) countryMap.put(c.Alpha3__c.toLowerCase(), c.Id);
                if (String.isNotBlank(c.Name)) countryMap.put(c.Name.toLowerCase(), c.Id);
            }
            
            for (Lead lead : leads) {
                // Solo asignar si CountryCode NO está vacío
                if (String.isNotBlank(lead.CountryCode)) {
                    String key = lead.CountryCode.toLowerCase().trim();
                    Id matchedId = countryMap.get(key);
                    if (matchedId == null && String.isNotBlank(lead.Country)) {
                        matchedId = countryMap.get(lead.Country.toLowerCase().trim());
                    }
                    lead.CountryLookup__c = matchedId;
                } else if (String.isNotBlank(lead.Country) && String.isNotBlank(lead.CountryCode)) {
                    // Caso improbable pero: tiene Country sin CountryCode por otra razón
                    String key = lead.Country.toLowerCase().trim();
                    lead.CountryLookup__c = countryMap.get(key);
                }
                // Si llega aquí con CountryCode=null, ya se limpió arriba
            }
            
        } finally {
            isExecuting = false;
        }
    }
}