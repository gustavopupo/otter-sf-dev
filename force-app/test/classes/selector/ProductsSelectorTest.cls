@isTest
public class ProductsSelectorTest {

    @isTest
    static void selectByIdShouldReturnExpectedFields() {
        // Given
        Product2 product = new Product2();
        product.Name = 'Test';
        product.Uuid__c = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        product.IsActive = true;
        insert product;

        // When
        List<Product2> products = ProductsSelector.newInstance().selectByUuid(new Set<String>{ '62b18b17-c827-49a8-bc3d-52ee0d18e8f1' });

        // Then
        Assert.areEqual('Test', products[0].Name);
        Assert.areEqual('62b18b17-c827-49a8-bc3d-52ee0d18e8f1', products[0].Uuid__c);
    }

}