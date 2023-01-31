public class PricebooksSelector extends fflib_SObjectSelector implements IPricebooksSelector {

    public static IPricebooksSelector newInstance() {
        return (IPricebooksSelector) Application.Selector.newInstance(Pricebook2.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Pricebook2.Id,
            Pricebook2.Name
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Pricebook2.SObjectType;
    }

    public List<Pricebook2> selectByName(Set<String> names) {
        return (List<Pricebook2>) Database.query(
            newQueryFactory()
                .setCondition('Name IN :names')
                .toSOQL()
        );
    }

}