@isTest
public class OpportunitiesServiceTest {

    @isTest
    static void callingServiceShouldCreateOpportunityLineItemsAndCommit() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IPricebookEntriesSelector pricebookEntriesSelectorMock = (IPricebookEntriesSelector) mocks.mock(IPricebookEntriesSelector.class);

        // Given
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<ProductWithQuantity> products = new List<ProductWithQuantity>{
            new ProductWithQuantity(fflib_IDGenerator.generate(Product2.SObjectType), 1),
            new ProductWithQuantity(fflib_IDGenerator.generate(Product2.SObjectType), 2),
            new ProductWithQuantity(fflib_IDGenerator.generate(Product2.SObjectType), 3)
        };
        PricebookEntry mockPricebookEntry1 = new PricebookEntry();
        mockPricebookEntry1.Pricebook2Id = Test.getStandardPricebookId();
        mockPricebookEntry1.Product2Id = products[0].productId;
        mockPricebookEntry1.UnitPrice = 10;
        mockPricebookEntry1.IsActive = true;
        PricebookEntry mockPricebookEntry2 = new PricebookEntry();
        mockPricebookEntry2.Pricebook2Id = Test.getStandardPricebookId();
        mockPricebookEntry2.Product2Id = products[1].productId;
        mockPricebookEntry2.UnitPrice = 20;
        mockPricebookEntry2.IsActive = true;
        PricebookEntry mockPricebookEntry3 = new PricebookEntry();
        mockPricebookEntry3.Pricebook2Id = Test.getStandardPricebookId();
        mockPricebookEntry3.Product2Id = products[2].productId;
        mockPricebookEntry3.UnitPrice = 30;
        mockPricebookEntry3.IsActive = true;
        mocks.startStubbing();
        mocks.when(pricebookEntriesSelectorMock.SObjectType()).thenReturn(PricebookEntry.SObjectType);
        mocks.when(pricebookEntriesSelectorMock.selectByPricebookAndProducts(Test.getStandardPricebookId(), new Set<Id>{ products[0].productId, products[1].productId, products[2].productId }))
            .thenReturn(new List<PricebookEntry>{ mockPricebookEntry1, mockPricebookEntry2, mockPricebookEntry3 });
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(pricebookEntriesSelectorMock);

        // When
        Set<Id> opportunityLineItemsIds = OpportunitiesService.createOpportunityLineItems(opportunityId, Test.getStandardPricebookId(), products);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                OpportunityLineItem.OpportunityId => opportunityId,
                OpportunityLineItem.Product2Id => products[0].productId,
                OpportunityLineItem.Quantity => products[0].quantity,
                OpportunityLineItem.UnitPrice => 10
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                OpportunityLineItem.OpportunityId => opportunityId,
                OpportunityLineItem.Product2Id => products[1].productId,
                OpportunityLineItem.Quantity => products[1].quantity,
                OpportunityLineItem.UnitPrice => 20
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                OpportunityLineItem.OpportunityId => opportunityId,
                OpportunityLineItem.Product2Id => products[2].productId,
                OpportunityLineItem.Quantity => products[2].quantity,
                OpportunityLineItem.UnitPrice => 30
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @isTest
    static void callingServiceShouldMarkOpportunitiesAsClosedWonAndCommit() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        // Given
        Application.UnitOfWork.setMock(uowMock);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        
        // When
        OpportunitiesService.markAsClosedWon(new Set<Id>{ opportunityId });

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(
            fflib_Match.sObjectsWith(new List<Map<SObjectField, Object>> {
                new Map<SObjectField, Object> {
                    Opportunity.Id => opportunityId,
                    Opportunity.StageName => Opportunities.CLOSED_WON_STAGE_API_NAME
                }
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

    @isTest
    static void callingServiceShouldSetPricebookAndCommit() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        // Given
        Application.UnitOfWork.setMock(uowMock);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id pricebookId = fflib_IDGenerator.generate(Pricebook2.SObjectType);
        
        // When
        OpportunitiesService.setPricebook(new Set<Id>{ opportunityId }, pricebookId);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty(
            fflib_Match.sObjectsWith(new List<Map<SObjectField, Object>> {
                new Map<SObjectField, Object> {
                    Opportunity.Id => opportunityId,
                    Opportunity.Pricebook2Id => pricebookId
                }
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

}
