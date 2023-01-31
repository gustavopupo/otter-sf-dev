public class LeadConversionQueueable implements Queueable {

    private Lead lead;
    private List<ProductWithQuantity> products;

    public LeadConversionQueueable(Lead lead) {
        this.lead = lead;
        this.products = new List<ProductWithQuantity>();
    }

    public LeadConversionQueueable(Lead lead, List<ProductWithQuantity> products) {
        this.lead = lead;
        this.products = products;
    }

    public void execute(QueueableContext context) {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.id);

        LeadStatus convertedStatus = LeadStatusesSelector.newInstance().selectConvertedStatus();
        lc.setConvertedStatus(convertedStatus.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);

        if (lcr.isSuccess() && !products.isEmpty()) {
            Lead convertedLead = LeadsSelector.newInstance().selectById(new Set<Id>{ lead.Id })[0];
            List<Pricebook2> pricebooks = PricebooksSelector.newInstance().selectByName(new Set<String>{ SelfSignUpServiceImpl.PRICEBOOK_NAME_FOR_NEW_OPPORTUNITIES });

            if (pricebooks.isEmpty()) {
                throw new LeadConversionQueueableException('Could not find a Pricebook named \'' + SelfSignUpServiceImpl.PRICEBOOK_NAME_FOR_NEW_OPPORTUNITIES + '\'.');
            }

            OpportunitiesService.setPricebook(new Set<Id>{ convertedLead.ConvertedOpportunityId }, pricebooks[0].Id);
            OpportunitiesService.createOpportunityLineItems(convertedLead.ConvertedOpportunityId, pricebooks[0].Id, products);
            OpportunitiesService.markAsClosedWon(new Set<Id>{ convertedLead.ConvertedOpportunityId });
        }
    }

    public class LeadConversionQueueableException extends Exception {}

}