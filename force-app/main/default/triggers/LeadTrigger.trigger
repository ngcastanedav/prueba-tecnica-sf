trigger LeadTrigger on Lead (before insert, before update) {
    
    if (Trigger.isInsert) {
        LeadTriggerHandler.populateCountryLookup(Trigger.new, null);
    } else if (Trigger.isUpdate) {
        LeadTriggerHandler.populateCountryLookup(Trigger.new, Trigger.oldMap);
    }
}