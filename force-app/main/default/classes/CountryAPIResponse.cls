/**
 * Clase interna para deserializar la respuesta JSON de countrylayer.com
 * Estructura basada en: http://api.countrylayer.com/v2/all?access_key=API_KEY
 */
public class CountryAPIResponse {
    
    public String name;
    public String alpha2Code;
    public String alpha3Code;
    public String capital;
    public String region;
    public List<RegionalBloc> regionalBlocs;
    
    // Clase interna para los bloques regionales
    public class RegionalBloc {
        public String acronym;
        public String name;
        public List<String> otherAcronyms;
        public List<String> otherNames;
    }
    
    /**
     * Extrae solo los acrónimos de los bloques regionales
     * @return String con acrónimos separados por coma
     */
    public String getBlocAcronyms() {
        if (regionalBlocs == null || regionalBlocs.isEmpty()) {
            return null;
        }
        List<String> acronyms = new List<String>();
        for (RegionalBloc bloc : regionalBlocs) {
            if (bloc.acronym != null) {
                acronyms.add(bloc.acronym);
            }
        }
        return String.join(acronyms, ', ');
    }
    
    /**
     * Convierte la respuesta de la API a un registro Country__c
     * @return Country__c
     */
    public Country__c toCountry() {
        Country__c c = new Country__c();
        c.Name = this.name;
        c.Alpha2__c = this.alpha2Code;
        c.Alpha3__c = this.alpha3Code;
        c.Capital__c = this.capital;
        c.Region__c = this.region;
        c.Blocs__c = this.getBlocAcronyms();
        c.BlocsShort__c = this.getBlocAcronyms();
        c.ExternalId__c = this.alpha2Code; // Usamos Alpha2 como ID externo
        return c;
    }
}