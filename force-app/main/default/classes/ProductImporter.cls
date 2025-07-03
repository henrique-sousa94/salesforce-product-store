public with sharing class ProductImporter {

    @AuraEnabled
    public static void importProducts() {
        String token = DummyJsonApi.login();
        List<Map<String, Object>> products = DummyJsonApi.getProducts(token, '');

        // Já existentes (por SKU)
        Set<String> existingSkus = new Set<String>();
        for (Product2 p : [SELECT ProductCode FROM Product2]) {
            existingSkus.add(p.ProductCode);
        }

        // Contadores por categoria
        Map<String, Integer> countPerCat = new Map<String, Integer>();
        Map<String, Decimal> sumPerCat = new Map<String, Decimal>();
        for (AggregateResult ar : [
            SELECT Category__c cat, COUNT(Id) c, SUM(Price__c) s
            FROM Product2
            GROUP BY Category__c
        ]) {
            String cat = (String)ar.get('cat');
            countPerCat.put(cat, (Integer)ar.get('c'));
            sumPerCat.put(cat, (Decimal)ar.get('s'));
        }

        List<Product2> inserts = new List<Product2>();

        for (Map<String, Object> p : products) {
            String sku = (String)p.get('sku');
            if (existingSkus.contains(sku)) continue;

            String cat = (String)p.get('category');
            Decimal price = Decimal.valueOf(String.valueOf(p.get('price')));
            Integer count = countPerCat.containsKey(cat) ? countPerCat.get(cat) : 0;
            Decimal sum = sumPerCat.containsKey(cat) ? sumPerCat.get(cat) : 0;

            Decimal stockDecimal = Decimal.valueOf(String.valueOf(p.get('stock')));
            Integer stockInt = stockDecimal.intValue();

            if (count < 100 && (sum + price) <= 10000) {
                Product2 rec = new Product2(
                    Name = (String)p.get('title'),
                    Description = (String)p.get('description'),
                    Category__c = cat,
                    Brand__c = (String)p.get('brand'),
                    Price__c = price,
                    Stock__c = stockInt,
                    Thumbnail__c = (List<Object>)p.get('images') != null && !((List<Object>)p.get('images')).isEmpty() ? (String)((List<Object>)p.get('images')).get(0) : null,
                    ProductCode = sku
                );
                inserts.add(rec);

                countPerCat.put(cat, count + 1);
                sumPerCat.put(cat, sum + price);
            }
        }

        if (!inserts.isEmpty()) insert inserts;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductDTO> getProducts(String categoryFilter, String brandFilter, String nameFilter) {
        String namePattern = '%' + nameFilter + '%';
        String baseQuery = 'SELECT Id, Name, Brand__c, Category__c, Price__c, Stock__c, Thumbnail__c FROM Product2';
        List<String> conditions = new List<String>();

        if (String.isNotBlank(categoryFilter)) {
            conditions.add('Category__c = :categoryFilter');
        }
        if (String.isNotBlank(brandFilter)) {
            conditions.add('Brand__c = :brandFilter');
        }
        if (String.isNotBlank(nameFilter)) {
            conditions.add('Name LIKE :namePattern');
        }

        String whereClause = '';
        if (!conditions.isEmpty()) {
            whereClause = ' WHERE ' + String.join(conditions, ' AND ');
        }

        String fullQuery = baseQuery + whereClause + ' ORDER BY CreatedDate DESC';
        System.debug('SOQL = ' + fullQuery);

        List<Product2> products = Database.query(fullQuery);

        List<ProductDTO> dtos = new List<ProductDTO>();
        for (Product2 p : products) {
            dtos.add(new ProductDTO(p));
        }
        return dtos;
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getExistingCategories() {
        List<String> categories = new List<String>();
        for (AggregateResult ar : [
            SELECT Category__c
            FROM Product2
            WHERE Category__c != null
            GROUP BY Category__c
            ORDER BY Category__c
        ]) {
            categories.add((String)ar.get('Category__c'));
        }
        return categories;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getExistingBrands() {
        List<String> brands = new List<String>();
        for (AggregateResult ar : [
            SELECT Brand__c
            FROM Product2
            WHERE Brand__c != null
            GROUP BY Brand__c
            ORDER BY Brand__c
        ]) {
            brands.add((String)ar.get('Brand__c'));
        }
        return brands;
    }

    public class ProductDTO {
        @AuraEnabled public String Id;
        @AuraEnabled public String Name;
        @AuraEnabled public String Brand;
        @AuraEnabled public String Category;
        @AuraEnabled public Decimal Price;
        @AuraEnabled public Integer Stock;
        @AuraEnabled public String Thumbnail;

        public ProductDTO(Product2 p) {
            this.Id = p.Id;
            this.Name = p.Name;
            this.Brand = p.Brand__c != null ? p.Brand__c : '';
            this.Category = p.Category__c != null ? p.Category__c : '';
            this.Price = p.Price__c != null ? p.Price__c : 0;
            this.Stock = p.Stock__c != null ? p.Stock__c.intValue() : 0;
            this.Thumbnail = p.Thumbnail__c != null ? p.Thumbnail__c : '';
        }
    }

}