public class LeadsServiceImpl implements ILeadsService {

    public Id enqueueConversionJob(Lead lead, List<ProductWithQuantity> products) {
        return System.enqueueJob(new LeadConversionQueueable(lead, products));
    }

}