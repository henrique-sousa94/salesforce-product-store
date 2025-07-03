trigger Product2PreventDuplicateCode on Product2 (before insert, before update) {
    // Chama a lógica central
    Product2DuplicateChecker.checkDuplicateProductCodes(Trigger.new);
}