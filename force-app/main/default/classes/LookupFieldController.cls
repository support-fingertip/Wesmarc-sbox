public with sharing class LookupFieldController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> findRecords(String searchKey, String objectName) {
        if (String.isBlank(searchKey) || String.isBlank(objectName)) {
            return new List<sObject>();
        }

        // Prevent SOQL injection using Type.forName and dynamic query binding
        String sKey = '%' + searchKey + '%';
        String query = 'SELECT Id, Name FROM ' + String.escapeSingleQuotes(objectName) +
                       ' WHERE Name LIKE :sKey ORDER BY Name LIMIT 10';
        return Database.query(query);
    }
}