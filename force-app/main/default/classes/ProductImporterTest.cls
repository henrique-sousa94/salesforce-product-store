@isTest
public class ProductImporterTest {
    @isTest
    static void testGetExistingCategoriesAndBrands() {
        // Insert test data
        Product2 p = new Product2(
            Name = 'Test Product',
            ProductCode = 'SKU_TEST',
            Category__c = 'TestCategory',
            Brand__c = 'TestBrand'
        );
        insert p;

        Test.startTest();
        List<String> categories = ProductImporter.getExistingCategories();
        List<String> brands = ProductImporter.getExistingBrands();
        Test.stopTest();

        System.assert(categories.contains('TestCategory'), 'Category should be present');
        System.assert(brands.contains('TestBrand'), 'Brand should be present');
    }

    @isTest
    static void testGetProducts() {
        Product2 p = new Product2(
            Name = 'Product Filter',
            ProductCode = 'SKU_FILTER',
            Category__c = 'CategoryFilter',
            Brand__c = 'BrandFilter',
            Price__c = 100
        );
        insert p;

        Test.startTest();
        List<ProductImporter.ProductDTO> productsAll = ProductImporter.getProducts('', '', '');
        System.assert(!productsAll.isEmpty(), 'Should return products');

        List<ProductImporter.ProductDTO> productsCat = ProductImporter.getProducts('CategoryFilter', '', '');
        System.assert(!productsCat.isEmpty(), 'Should filter by category');

        List<ProductImporter.ProductDTO> productsBrand = ProductImporter.getProducts('', 'BrandFilter', '');
        System.assert(!productsBrand.isEmpty(), 'Should filter by brand');

        List<ProductImporter.ProductDTO> productsName = ProductImporter.getProducts('', '', 'Product Filter');
        System.assert(!productsName.isEmpty(), 'Should filter by name');
        Test.stopTest();
    }

    @isTest
    static void testImportProducts() {
        // To test importProducts, mock DummyJsonApi methods if necessary.
        // This is often done via a Stub API or dependency injection.
        // For this example, we will just call the method to ensure no exceptions.

        Test.startTest();
        ProductImporter.importProducts();
        Test.stopTest();
    }
}
