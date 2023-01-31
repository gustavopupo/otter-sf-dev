public interface IOpportunitiesService {
    Set<Id> createOpportunityLineItems(Id opportunityId, Id pricebookId, List<ProductWithQuantity> products);
    void markAsClosedWon(Set<Id> opportunityIds);
    void setPricebook(Set<Id> opportunityIds, Id pricebook2Id);
}