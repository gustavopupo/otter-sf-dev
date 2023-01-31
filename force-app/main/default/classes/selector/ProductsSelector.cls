public class ProductsSelector extends fflib_SObjectSelector implements IProductsSelector {

    public static IProductsSelector newInstance() {
        return (IProductsSelector) Application.Selector.newInstance(Product2.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Name,
            Product2.Uuid__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Product2.SObjectType;
    }

    public List<Product2> selectByUuid(Set<String> uuids) {
        return (List<Product2>) Database.query(
            newQueryFactory()
                .setCondition('Uuid__c IN :uuids')
                .toSOQL()
        );
    }

}