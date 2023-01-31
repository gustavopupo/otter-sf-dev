public class PricebookEntriesSelector extends fflib_SObjectSelector implements IPricebookEntriesSelector {

    public static IPricebookEntriesSelector newInstance() {
        return (IPricebookEntriesSelector) Application.Selector.newInstance(PricebookEntry.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            PricebookEntry.Id,
            PricebookEntry.Name,
            PricebookEntry.Pricebook2Id,
            PricebookEntry.Product2Id,
            PricebookEntry.UnitPrice
        };
    }

    public Schema.SObjectType getSObjectType() {
        return PricebookEntry.SObjectType;
    }

    public List<PricebookEntry> selectByPricebookAndProducts(Id pricebookId, Set<Id> productIds) {
        return (List<PricebookEntry>) Database.query(
            newQueryFactory()
                .setCondition('Pricebook2Id = :pricebookId AND Product2Id IN :productIds')
                .toSOQL()
        );
    }

}