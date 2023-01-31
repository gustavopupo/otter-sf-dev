public with sharing class LeadsService {

    public static Id enqueueConversionJob(Lead lead, List<ProductWithQuantity> products) {
        return service().enqueueConversionJob(lead, products);
    }

    private static ILeadsService service() {
        return (ILeadsService) Application.Service.newInstance(ILeadsService.class);
    }

}