public class AccountsSelector extends fflib_SObjectSelector implements IAccountsSelector {

    public static IAccountsSelector newInstance() {
        return (IAccountsSelector) Application.Selector.newInstance(Account.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Account.Id,
            Account.Name
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<Account> selectByName(Set<String> names) {
        return (List<Account>) Database.query(
            newQueryFactory()
                .setCondition('Name IN :names')
                .toSOQL()
        );
    }

}