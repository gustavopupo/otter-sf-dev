public interface IPricebookEntriesSelector extends fflib_ISObjectSelector  {
    List<PricebookEntry> selectByPricebookAndProducts(Id pricebookId, Set<Id> productIds);
}