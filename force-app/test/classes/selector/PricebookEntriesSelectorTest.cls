@isTest
public class PricebookEntriesSelectorTest {

    @isTest
    static void selectByPricebookAndProductsShouldReturnExpectedFields() {
        // Given
        Product2 product = new Product2();
        product.Name = 'Test';
        product.IsActive = true;
        insert product;
        PricebookEntry pricebookEntry = new PricebookEntry();
        pricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        pricebookEntry.Product2Id = product.Id;
        pricebookEntry.UnitPrice = 10;
        pricebookEntry.IsActive = true;
        insert pricebookEntry;

        // When
        List<PricebookEntry> pricebookEntries = PricebookEntriesSelector.newInstance().selectByPricebookAndProducts(Test.getStandardPricebookId(), new Set<Id>{ product.Id });

        // Then
        Assert.isTrue(!pricebookEntries.isEmpty());
        Assert.areEqual('Test', pricebookEntries[0].Name);
        Assert.areEqual(10, pricebookEntries[0].UnitPrice);
    }

}