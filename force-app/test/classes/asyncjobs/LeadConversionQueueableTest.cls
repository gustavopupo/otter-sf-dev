@isTest
public class LeadConversionQueueableTest {

    @isTest
    static void queueingShouldConvertLead() {
        // Given
        Lead lead = new Lead();
        lead.FirstName = 'Test';
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.LeadSource = 'Test';
        insert lead;

        // When
        Test.startTest();
        System.enqueueJob(new LeadConversionQueueable(lead));
        Test.stopTest();

        // Then
        lead = [SELECT Id, ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :lead.Id LIMIT 1];
        Opportunity opportunity = [SELECT Id, Name, LeadSource FROM Opportunity WHERE Id = :lead.ConvertedOpportunityId LIMIT 1];
        Account account = [SELECT Id, Name, AccountSource FROM Account WHERE Id = :lead.ConvertedAccountId LIMIT 1];
        Contact contact = [SELECT Id, Name, LeadSource FROM Contact WHERE Id = :lead.ConvertedContactId LIMIT 1];
        Assert.isNotNull(opportunity);
        Assert.isNotNull(account);
        Assert.isNotNull(contact);
    }

}