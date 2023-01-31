@isTest
public class LeadsSelectorTest {

    @isTest
    static void selectByCompanyShouldReturnExpectedFields() {
        // Given
        Lead lead = new Lead();
        lead.LastName = 'Test';
        lead.Company = 'Test';
        insert lead;

        // When
        List<Lead> leads = LeadsSelector.newInstance().selectByCompany(new Set<String>{ 'Test' });

        // Then
        Assert.areEqual('Test', leads[0].Name);
        Assert.areEqual('Test', leads[0].Company);
    }

}