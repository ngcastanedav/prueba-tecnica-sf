# Prueba Técnica Salesforce

Implementación de los siguientes requisitos:

## 1. Integración con API de países (countrylayer.com)

- Sincronización diaria de datos de países a objeto personalizado `Country__c`
- Campos: Name, Alpha2Code, Alpha3Code, Capital, Region, RegionalBlocs
- Clase `CountrySyncSchedulable` programada para ejecución diaria a las 3:00 AM
- Mock para tests unitarios (`CountryAPIMock`, `CountryAPIMockError`)

## 2. Trigger en Lead

- `LeadTrigger` (before insert, before update) asigna automáticamente el lookup `CountryLookup__c`
- Búsqueda por `CountryCode` (código ISO Alpha2) y fallback a `Country`
- Campos fórmula en Lead: Country Capital, Country Region, Country Alpha2, Country Alpha3, Country Blocs
- Tests unitarios incluidos (`LeadTriggerTest`)

## 3. Validation Rule en Lead

- `Owner_Change_Validation`: impide cambiar Owner si faltan campos requeridos
- Lógica diferenciada por perfil:
  - **System Administrator**: solo necesita Lead Source
  - **Contract Manager**: necesita Country y Lead Source (no Employees)
  - **Resto de perfiles**: necesita Country, Lead Source y No. of Employees

## 4. Flow para tracking de Owner

- `Set_Owner_Since_Lead`: Record-Triggered Flow que guarda timestamp en `Owner_Since__c`
- Se ejecuta solo cuando cambia el campo OwnerId

## Estructura del proyecto

force-app/main/default/
├── classes/ # Clases Apex y tests
│ ├── CountryAPIService.cls
│ ├── CountryAPIServiceTest.cls
│ ├── CountryAPIResponse.cls
│ ├── CountrySyncSchedulable.cls
│ ├── CountrySyncSchedulableTest.cls
│ ├── CountryAPIMock.cls
│ ├── CountryAPIMockError.cls
│ ├── LeadTriggerHandler.cls
│ └── LeadTriggerTest.cls
├── triggers/
│ └── LeadTrigger.trigger
├── flows/
│ └── Set_Owner_Since_Lead.flow-meta.xml
├── objects/
│ ├── Country__c/
│ └── Lead/
└── layouts/
└── Lead-Lead Layout.layout-meta.xml

## Configuración adicional necesaria

- **Remote Site Setting**: `http://api.countrylayer.com`
- **API Key**: configurar en `CountryAPIService.cls` (variable `API_KEY`)
- **Job programado**: `Daily Country Sync` con `CountrySyncSchedulable`