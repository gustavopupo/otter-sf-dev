public interface IProductsSelector extends fflib_ISObjectSelector  {
    List<Product2> selectByUuid(Set<String> uuids);
}