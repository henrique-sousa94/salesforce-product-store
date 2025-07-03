public with sharing class ProductViewer {
    @AuraEnabled(cacheable=true)
    public static List<String> getCategories() {
        return new List<String>([SELECT Name FROM CategoryControl__c].stream().map(c -> c.Name));
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBrands() {
        return new List<String>([SELECT Brand__c FROM Product2 GROUP BY Brand__c ORDER BY Brand__c ASC].stream().map(b -> (String)b.get('Brand__c')));
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductDTO> getProducts(String categoryFilter, String brandFilter) {
        String query = 'SELECT Id, Name, Brand__c, Category__c, Stock__c, Thumbnail__c, Price__c FROM Product2 WHERE IsActive = true';
        if(String.isNotBlank(categoryFilter)) {
            query += ' AND Category__c = :categoryFilter';
        }
        if(String.isNotBlank(brandFilter)) {
            query += ' AND Brand__c = :brandFilter';
        }
        List<Product2> products = Database.query(query);

        List<ProductDTO> dtos = new List<ProductDTO>();
        for(Product2 p : products) {
            dtos.add(new ProductDTO(p));
        }
        return dtos;
    }

    public class ProductDTO {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Brand;
        @AuraEnabled public String Category;
        @AuraEnabled public Integer Stock;
        @AuraEnabled public Decimal Price;
        @AuraEnabled public String Thumbnail;

        public ProductDTO(Product2 p) {
            this.Id = p.Id;
            this.Name = p.Name;
            this.Brand = p.Brand__c;
            this.Category = p.Category__c;
            this.Stock = (p.Stock__c == null) ? 0 : Integer.valueOf(p.Stock__c);
            this.Price = p.Price__c;
            this.Thumbnail = p.Thumbnail__c;
        }
    }
}
