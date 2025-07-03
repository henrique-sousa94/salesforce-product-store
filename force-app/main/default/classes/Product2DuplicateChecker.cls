public class Product2DuplicateChecker {
    public static void checkDuplicateProductCodes(List<Product2> newProducts) {
        // Set of ProductCodes to validate
        Set<String> codes = new Set<String>();
        for (Product2 p : newProducts) {
            if (String.isNotBlank(p.ProductCode)) {
                codes.add(p.ProductCode.trim());
            }
        }

        if (codes.isEmpty()) {
            return;
        }

        // Map ProductCode => existing Product2 record
        Map<String, Product2> existing = new Map<String, Product2>();
        for (Product2 p : [
            SELECT Id, ProductCode
            FROM Product2
            WHERE ProductCode IN :codes
        ]) {
            existing.put(p.ProductCode.trim(), p);
        }

        // For each new or updated record
        for (Product2 p : newProducts) {
            if (String.isNotBlank(p.ProductCode)) {
                String code = p.ProductCode.trim();

                if (existing.containsKey(code)) {
                    Product2 existingRec = existing.get(code);

                    // Allow update if it's the same record
                    if (p.Id == null || p.Id != existingRec.Id) {
                        p.ProductCode.addError('A product with this Product Code (SKU) already exists.');
                    }
                }
            }
        }
    }
}
