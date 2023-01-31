public interface IPricebooksSelector extends fflib_ISObjectSelector  {
    List<Pricebook2> selectByName(Set<String> names);
}