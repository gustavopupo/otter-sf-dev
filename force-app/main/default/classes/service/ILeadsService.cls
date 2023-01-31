public interface ILeadsService {
    Id enqueueConversionJob(Lead lead, List<ProductWithQuantity> products);
}