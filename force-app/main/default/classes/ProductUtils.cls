public with sharing class ProductUtils {
    @AuraEnabled(cacheable=true)
    public static List<String> getFamilyPicklistValues() {
        List<String> values = new List<String>();
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            values.add(entry.getValue());
        }
        return values;
    }
}
