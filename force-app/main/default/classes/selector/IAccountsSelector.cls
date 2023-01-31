public interface IAccountsSelector extends fflib_ISObjectSelector  {
    List<Account> selectByName(Set<String> names);
}