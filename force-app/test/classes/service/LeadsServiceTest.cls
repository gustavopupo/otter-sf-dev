@isTest
public class LeadsServiceTest {

    @isTest
    static void callingServiceShouldEnqueueConversionJobAndCallOpportunitiesService() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService opportunitiesServiceMock = (IOpportunitiesService) mocks.mock(IOpportunitiesService.class);
        IPricebooksSelector pricebooksSelectorMock = (IPricebooksSelector) mocks.mock(IPricebooksSelector.class);

        // Given
        ProductWithQuantity productWithQuantity1 = 
            new ProductWithQuantity(fflib_IDGenerator.generate(Product2.SObjectType), 1);
        ProductWithQuantity productWithQuantity2 =
            new ProductWithQuantity(fflib_IDGenerator.generate(Product2.SObjectType), 2);
        List<ProductWithQuantity> productsWithQuantities = 
            new List<ProductWithQuantity>{ productWithQuantity1, productWithQuantity2 };
        Lead mockLead = new Lead();
        mockLead.Company = 'Test';
        mockLead.LastName = 'Test';
        insert mockLead;
        Pricebook2 mockPricebook = new Pricebook2();
        mockPricebook.Id = fflib_IDGenerator.generate(Pricebook2.SObjectType);
        mockPricebook.Name = 'Test Pricebook';
        mockPricebook.IsActive = true;
        mocks.startStubbing();
        mocks.when(pricebooksSelectorMock.SObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(pricebooksSelectorMock.selectByName((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Pricebook2>{ mockPricebook });
        mocks.stopStubbing();
        Application.Service.setMock(IOpportunitiesService.class, opportunitiesServiceMock);
        Application.Selector.setMock(pricebooksSelectorMock);

        // When
        Test.startTest();
        Id jobId = LeadsService.enqueueConversionJob(mockLead, productsWithQuantities);
        Test.stopTest();

        // Then
        mockLead = [SELECT Id, ConvertedOpportunityId, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :mockLead.Id LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Id = :mockLead.ConvertedOpportunityId LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE Id = :mockLead.ConvertedAccountId LIMIT 1];
        Contact contact = [SELECT Id FROM Contact WHERE Id = :mockLead.ConvertedContactId LIMIT 1];
        Assert.isNotNull(opportunity);
        Assert.isNotNull(account);
        Assert.isNotNull(contact);
        ((IOpportunitiesService) mocks.verify(opportunitiesServiceMock, 1)).setPricebook(new Set<Id>{ mockLead.ConvertedOpportunityId }, mockPricebook.Id);
        ((IOpportunitiesService) mocks.verify(opportunitiesServiceMock, 1)).createOpportunityLineItems(mockLead.ConvertedOpportunityId, mockPricebook.Id, productsWithQuantities);
        ((IOpportunitiesService) mocks.verify(opportunitiesServiceMock, 1)).markAsClosedWon(new Set<Id>{ mockLead.ConvertedOpportunityId });
    }

}