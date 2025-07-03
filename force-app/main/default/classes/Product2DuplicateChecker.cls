public class Product2DuplicateChecker {
    public static void checkDuplicateProductCodes(List<Product2> newProducts) {
        // Conjunto de ProductCodes a verificar
        Set<String> codes = new Set<String>();
        for(Product2 p : newProducts) {
            if(String.isNotBlank(p.ProductCode)) {
                codes.add(p.ProductCode.trim());
            }
        }

        if(codes.isEmpty()) {
            return;
        }

        // Mapeia ProductCode => existing Product2
        Map<String, Product2> existing = new Map<String, Product2>();
        for(Product2 p : [
            SELECT Id, ProductCode 
            FROM Product2
            WHERE ProductCode IN :codes
        ]) {
            existing.put(p.ProductCode.trim(), p);
        }

        // Para cada registro novo/alterado
        for(Product2 p : newProducts) {
            if(String.isNotBlank(p.ProductCode)) {
                String code = p.ProductCode.trim();

                if(existing.containsKey(code)) {
                    Product2 existingRec = existing.get(code);

                    // Permite update se for o mesmo registro
                    if(p.Id == null || p.Id != existingRec.Id) {
                        p.ProductCode.addError('Já existe um produto com este Product Code (SKU).');
                    }
                }
            }
        }
    }
}