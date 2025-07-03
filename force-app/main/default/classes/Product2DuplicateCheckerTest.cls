@isTest
public class Product2DuplicateCheckerTest {
    @isTest
    static void testDuplicateCheck_noDuplicates() {
        // Create a Product2 record with a unique ProductCode
        Product2 p = new Product2(
            Name = 'Test Product',
            ProductCode = 'SKU_UNIQUE'
        );
        insert p;

        // Create a new product with a different ProductCode
        Product2 newP = new Product2(
            Name = 'New Product',
            ProductCode = 'SKU_NEW'
        );

        Test.startTest();
        Product2DuplicateChecker.checkDuplicateProductCodes(new List<Product2>{newP});
        Test.stopTest();
    }

    @isTest
    static void testDuplicateCheck_withDuplicate() {
        // Insert an existing Product2 record
        Product2 p = new Product2(
            Name = 'Existing Product',
            ProductCode = 'SKU_DUPLICATE'
        );
        insert p;

        // Create another record with the same ProductCode
        Product2 duplicateP = new Product2(
            Name = 'Duplicate Product',
            ProductCode = 'SKU_DUPLICATE'
        );

        Test.startTest();
        try {
            Product2DuplicateChecker.checkDuplicateProductCodes(new List<Product2>{duplicateP});
            System.assert(false, 'Expected an error due to duplicate ProductCode.');
        } catch (DmlException e) {
            // Expected error
            System.assert(e.getMessage().contains('already exists'));
        }
        Test.stopTest();
    }

    @isTest
    static void testDuplicateCheck_sameRecordUpdate() {
        // Insert initial record
        Product2 p = new Product2(
            Name = 'Existing Product',
            ProductCode = 'SKU_UPDATE'
        );
        insert p;

        // Update the same record (should not error)
        p.Name = 'Updated Name';

        Test.startTest();
        Product2DuplicateChecker.checkDuplicateProductCodes(new List<Product2>{p});
        Test.stopTest();
    }
}
