public class OpportunitiesServiceImpl implements IOpportunitiesService {

    public Set<Id> createOpportunityLineItems(Id opportunityId, Id pricebookId, List<ProductWithQuantity> products) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Map<Id, PricebookEntry> pricebookEntriesIndexedByProductId = getPricebookEntriesIndexedByProductId(pricebookId, products);

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        
        for (ProductWithQuantity product : products) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opportunityId;
            oli.Product2Id = product.productId;
            oli.Quantity = product.quantity;
            oli.UnitPrice = pricebookEntriesIndexedByProductId.get(product.productId).UnitPrice;
            
            opportunityLineItems.add(oli);
            
            uow.registerNew(oli);
        }
        
        uow.commitWork();

        Set<Id> opportunityLineItemsIds = new Set<Id>();

        for (OpportunityLineItem oli : opportunityLineItems) {
            opportunityLineItemsIds.add(oli.Id);
        }

        return opportunityLineItemsIds;
    }

    private Map<Id, PricebookEntry> getPricebookEntriesIndexedByProductId(Id pricebookId, List<ProductWithQuantity> products) {
        Set<Id> productIds = new Set<Id>();

        for (ProductWithQuantity product : products) {
            productIds.add(product.productId);
        }

        List<PricebookEntry> pricebookEntries = PricebookEntriesSelector.newInstance().selectByPricebookAndProducts(pricebookId, productIds);

        Map<Id, PricebookEntry> pricebookEntriesIndexedByProductId = new Map<Id, PricebookEntry>();

        for (PricebookEntry pricebookEntry : pricebookEntries) {
            pricebookEntriesIndexedByProductId.put(pricebookEntry.Product2Id, pricebookEntry);
        }

        return pricebookEntriesIndexedByProductId;
    }

    /**
     * Marks Opportunities as Closed Won.
     * 
     * @param opportunityIds The IDs of the Opportunities to be updated
     */
    public void markAsClosedWon(Set<Id> opportunityIds) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        IOpportunities opportunities = Opportunities.newInstance(Lists.sObjectsFromIdSet(opportunityIds, Opportunity.SObjectType));

        opportunities.markAsClosedWon();

        uow.registerDirty(opportunities.getRecords());
        uow.commitWork();
    }

    /**
     * Sets the Pricebook for the specified Opportunities..
     * 
     * @param opportunityIds The IDs of the Opportunities to be updated
     * @param pricebook2Id The ID of the Pricebook that will be set in the Opportunities
     */
    public void setPricebook(Set<Id> opportunityIds, Id pricebook2Id) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        IOpportunities opportunities = Opportunities.newInstance(Lists.sObjectsFromIdSet(opportunityIds, Opportunity.SObjectType));

        opportunities.setPricebook(pricebook2Id);

        uow.registerDirty(opportunities.getRecords());
        uow.commitWork();
    }

}