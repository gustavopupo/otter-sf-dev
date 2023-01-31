@isTest
public class PricebooksSelectorTest {

    @isTest
    static void selectByNameShouldReturnExpectedFields() {
        // Given
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'Test';
        pricebook.IsActive = true;
        insert pricebook;

        // When
        List<Pricebook2> pricebooks = PricebooksSelector.newInstance().selectByName(new Set<String>{ 'Test' });

        // Then
        Assert.isTrue(!pricebooks.isEmpty());
        Assert.areEqual('Test', pricebooks[0].Name);
    }

}