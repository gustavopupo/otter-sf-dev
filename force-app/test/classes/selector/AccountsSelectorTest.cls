@isTest
public class AccountsSelectorTest {

    @isTest
    static void selectByNameShouldReturnExpectedFields() {
        // Given
        Account account = new Account();
        account.Name = 'Test';
        insert account;

        // When
        List<Account> accounts = AccountsSelector.newInstance().selectByName(new Set<String>{ 'Test' });

        // Then
        Assert.areEqual('Test', accounts[0].Name);
    }

}