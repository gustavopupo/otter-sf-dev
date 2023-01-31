public with sharing class OpportunitiesService {

    public static Set<Id> createOpportunityLineItems(Id opportunityId, Id pricebookId, List<ProductWithQuantity> products) {
        return service().createOpportunityLineItems(opportunityId, pricebookId, products);
    }

    public static void markAsClosedWon(Set<Id> opportunityIds) {
        service().markAsClosedWon(opportunityIds);
    }

    public static void setPricebook(Set<Id> opportunityIds, Id pricebook2Id) {
        service().setPricebook(opportunityIds, pricebook2Id);
    }

    private static IOpportunitiesService service() {
        return (IOpportunitiesService) Application.Service.newInstance(IOpportunitiesService.class);
    }

}