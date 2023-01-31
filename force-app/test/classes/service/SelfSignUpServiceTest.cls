@isTest
public class SelfSignUpServiceTest {

    @isTest
    static void callingServiceWithNonMatchingAccountOrLeadShouldCreateRecordsAndCommit() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IOpportunitiesService opportunitiesServiceMock = (IOpportunitiesService) mocks.mock(IOpportunitiesService.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        ILeadsSelector leadsSelectorMock = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IProductsSelector productsSelectorMock = (IProductsSelector) mocks.mock(IProductsSelector.class);
        IPricebooksSelector pricebooksSelectorMock = (IPricebooksSelector) mocks.mock(IPricebooksSelector.class);

        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };
        Product2 mockProduct1 = new Product2();
        mockProduct1.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct1.Uuid__c = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        Product2 mockProduct2 = new Product2();
        mockProduct2.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct2.Uuid__c = '990db462-1354-4bb8-a0ae-85346ca601c4';
        Pricebook2 mockPricebook = new Pricebook2();
        mockPricebook.Id = fflib_IDGenerator.generate(Pricebook2.SObjectType);
        mockPricebook.Name = 'Test Pricebook';
        mockPricebook.IsActive = true;
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectByName(new Set<String>{ 'ACME' })).thenReturn(new List<Account>());
        mocks.when(leadsSelectorMock.SObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(leadsSelectorMock.selectByCompany(new Set<String>{ 'ACME' })).thenReturn(new List<Lead>());
        mocks.when(productsSelectorMock.SObjectType()).thenReturn(Product2.SObjectType);
        mocks.when(productsSelectorMock.selectByUuid(new Set<String>{ selectedProduct1.uuid, selectedProduct2.uuid })).thenReturn(new List<Product2>{ mockProduct1, mockProduct2 });
        mocks.when(pricebooksSelectorMock.SObjectType()).thenReturn(Pricebook2.SObjectType);
        mocks.when(pricebooksSelectorMock.selectByName((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Pricebook2>{ mockPricebook });
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Service.setMock(IOpportunitiesService.class, opportunitiesServiceMock);
        Application.Selector.setMock(accountsSelectorMock);
        Application.Selector.setMock(leadsSelectorMock);
        Application.Selector.setMock(productsSelectorMock);
        Application.Selector.setMock(pricebooksSelectorMock);

        // When
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                Account.Name => request.companyName,
                Account.Phone => request.phone,
                Account.BillingCity => request.address.city,
                Account.BillingCountry => request.address.country,
                Account.BillingPostalCode => request.address.postalCode,
                Account.BillingState => request.address.state,
                Account.BillingStreet => request.address.street
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                Contact.FirstName => request.firstName,
                Contact.LastName => request.lastName,
                Contact.Email => request.email,
                Contact.Phone => request.phone
            }),
            fflib_Match.eqSObjectField(Contact.AccountId),
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                Account.Name => request.companyName,
                Account.Phone => request.phone,
                Account.BillingCity => request.address.city,
                Account.BillingCountry => request.address.country,
                Account.BillingPostalCode => request.address.postalCode,
                Account.BillingState => request.address.state,
                Account.BillingStreet => request.address.street
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerNew(
            fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                Opportunity.Name => request.companyName,
                Opportunity.StageName => Opportunities.PROSPECTING_STAGE_API_NAME,
                Opportunity.Pricebook2Id => mockPricebook.Id
            })
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
        Assert.areEqual(SelfSignUpResponse.StatusCode.NO_MATCHING_ACCOUNT_OR_LEAD_FOUND, response.status);
    }

    @isTest
    static void callingServiceWithMatchingAccountShouldTakeNoAction() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IProductsSelector productsSelectorMock = (IProductsSelector) mocks.mock(IProductsSelector.class);

        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };
        Product2 mockProduct1 = new Product2();
        mockProduct1.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct1.Uuid__c = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        Product2 mockProduct2 = new Product2();
        mockProduct2.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct2.Uuid__c = '990db462-1354-4bb8-a0ae-85346ca601c4';
        Account mockAccount = new Account();
        mockAccount.Id = fflib_IDGenerator.generate(Account.SObjectType);
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectByName(new Set<String>{ 'ACME' })).thenReturn(new List<Account>{ mockAccount });
        mocks.when(productsSelectorMock.SObjectType()).thenReturn(Product2.SObjectType);
        mocks.when(productsSelectorMock.selectByUuid(new Set<String>{ selectedProduct1.uuid, selectedProduct2.uuid })).thenReturn(new List<Product2>{ mockProduct1, mockProduct2 });
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Selector.setMock(accountsSelectorMock);
        Application.Selector.setMock(productsSelectorMock);

        // When
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        // Then
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
        Assert.areEqual(SelfSignUpResponse.StatusCode.MATCHING_ACCOUNT_ALREADY_EXISTS, response.status);
    }

    @isTest
    static void callingServiceWithMatchingLeadShouldConvertLead() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        ILeadsService leadsServiceMock = (ILeadsService) mocks.mock(ILeadsService.class);
        IAccountsSelector accountsSelectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        ILeadsSelector leadsSelectorMock = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        IProductsSelector productsSelectorMock = (IProductsSelector) mocks.mock(IProductsSelector.class);

        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };
        Product2 mockProduct1 = new Product2();
        mockProduct1.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct1.Uuid__c = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        Product2 mockProduct2 = new Product2();
        mockProduct2.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct2.Uuid__c = '990db462-1354-4bb8-a0ae-85346ca601c4';
        Lead mockLead = new Lead();
        mockLead.Id = fflib_IDGenerator.generate(Lead.SObjectType);
        ProductWithQuantity productWithQuantity1 = 
            new ProductWithQuantity(mockProduct1.Id, selectedProduct1.quantity);
        ProductWithQuantity productWithQuantity2 =
            new ProductWithQuantity(mockProduct2.Id, selectedProduct2.quantity);
        List<ProductWithQuantity> productsWithQuantities = 
            new List<ProductWithQuantity>{ productWithQuantity1, productWithQuantity2 };
        mocks.startStubbing();
        mocks.when(accountsSelectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(accountsSelectorMock.selectByName(new Set<String>{ 'ACME' })).thenReturn(new List<Account>());
        mocks.when(leadsSelectorMock.SObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(leadsSelectorMock.selectByCompany(new Set<String>{ 'ACME' })).thenReturn(new List<Lead>{ mockLead });
        mocks.when(productsSelectorMock.SObjectType()).thenReturn(Product2.SObjectType);
        mocks.when(productsSelectorMock.selectByUuid(new Set<String>{ selectedProduct1.uuid, selectedProduct2.uuid })).thenReturn(new List<Product2>{ mockProduct1, mockProduct2 });
        mocks.stopStubbing();
        Application.UnitOfWork.setMock(uowMock);
        Application.Service.setMock(ILeadsService.class, leadsServiceMock);
        Application.Selector.setMock(accountsSelectorMock);
        Application.Selector.setMock(leadsSelectorMock);
        Application.Selector.setMock(productsSelectorMock);

        // When
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        // Then
        ((ILeadsService) mocks.verify(leadsServiceMock, 1)).enqueueConversionJob(
            (Lead) fflib_Match.sObjectWith(new Map<SObjectField, Object> {
                Lead.Id => mockLead.Id
            }),
            (List<ProductWithQuantity>) fflib_Match.eqList(productsWithQuantities)
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).commitWork();
        Assert.areEqual(SelfSignUpResponse.StatusCode.EXISTING_LEAD_QUEUED_FOR_CONVERSION, response.status);
    }

    @isTest
    static void givenRequestContainingAllRequiredFieldsWhenValidatingShouldNotReturnError() {
        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };

        // When
        String requiredFieldsErrorMessage = new SelfSignUpServiceImpl().validateRequiredFields(request);

        // Then
        Assert.isTrue(String.isEmpty(requiredFieldsErrorMessage));
    }

    @isTest
    static void givenRequestMissingRequiredFieldsWhenValidatingShouldReturnError() {
        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };

        // When
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        // Then
        Assert.areEqual(SelfSignUpResponse.StatusCode.MISSING_REQUIRED_FIELDS, response.status);
        Assert.isTrue(response.message.contains('companyName'));
        Assert.isTrue(response.message.contains('firstName'));
        Assert.isTrue(response.message.contains('lastName'));
    }

    @isTest
    static void givenRequestWithoutSelectedProductsWhenValidatingShouldReturnError() {
        // Given
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;

        // When
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        // Then
        Assert.areEqual(SelfSignUpResponse.StatusCode.SELECTED_PRODUCT_UUID_NOT_FOUND, response.status);
        Assert.isTrue(response.message.contains('Request does not contain any products'));
    }

    @isTest
    static void givenRequestWithNonExistingUuidWhenValidatingShouldReturnError() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductsSelector productsSelectorMock = (IProductsSelector) mocks.mock(IProductsSelector.class);

        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };
        Product2 mockProduct1 = new Product2();
        mockProduct1.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct1.Uuid__c = '437158c3-37f5-45bd-8f82-424e078764d7';
        Product2 mockProduct2 = new Product2();
        mockProduct2.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct2.Uuid__c = '1db48656-68a4-4ca0-bbb5-3d94df37ae17';
        mocks.startStubbing();
        mocks.when(productsSelectorMock.SObjectType()).thenReturn(Product2.SObjectType);
        mocks.when(productsSelectorMock.selectByUuid(new Set<String>{ selectedProduct1.uuid, selectedProduct2.uuid })).thenReturn(new List<Product2>{ mockProduct1, mockProduct2 });
        mocks.stopStubbing();
        Application.Selector.setMock(productsSelectorMock);

        // When
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        // Then
        Assert.areEqual(SelfSignUpResponse.StatusCode.SELECTED_PRODUCT_UUID_NOT_FOUND, response.status);
        Assert.isTrue(response.message.contains('62b18b17-c827-49a8-bc3d-52ee0d18e8f1'));
        Assert.isTrue(response.message.contains('990db462-1354-4bb8-a0ae-85346ca601c4'));
    }

    @isTest
    static void givenRequestWithExistingUuidsWhenValidatingShouldNotReturnError() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProductsSelector productsSelectorMock = (IProductsSelector) mocks.mock(IProductsSelector.class);

        // Given
        SelfSignUpRequest.SelectedProduct selectedProduct1 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct1.uuid = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        selectedProduct1.quantity = 1;
        SelfSignUpRequest.SelectedProduct selectedProduct2 = new SelfSignUpRequest.SelectedProduct();
        selectedProduct2.uuid = '990db462-1354-4bb8-a0ae-85346ca601c4';
        selectedProduct2.quantity = 2;
        SelfSignUpRequest.Address address = new SelfSignUpRequest.Address();
        address.city = 'New York';
        address.country = 'United States';
        address.postalCode = '10001';
        address.state = 'NY';
        address.street = '1000 Example Street';
        SelfSignUpRequest request = new SelfSignUpRequest();
        request.companyName = 'ACME';
        request.email = 'example@example.com';
        request.phone = '+1 (123) 456-7890';
        request.firstName = 'John';
        request.lastName = 'Doe';
        request.address = address;
        request.selectedProducts = new List<SelfSignUpRequest.SelectedProduct>{ selectedProduct1, selectedProduct2 };
        Product2 mockProduct1 = new Product2();
        mockProduct1.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct1.Uuid__c = '62b18b17-c827-49a8-bc3d-52ee0d18e8f1';
        Product2 mockProduct2 = new Product2();
        mockProduct2.Id = fflib_IDGenerator.generate(Product2.SObjectType);
        mockProduct2.Uuid__c = '990db462-1354-4bb8-a0ae-85346ca601c4';
        mocks.startStubbing();
        mocks.when(productsSelectorMock.SObjectType()).thenReturn(Product2.SObjectType);
        mocks.when(productsSelectorMock.selectByUuid(new Set<String>{ selectedProduct1.uuid, selectedProduct2.uuid })).thenReturn(new List<Product2>{ mockProduct1, mockProduct2 });
        mocks.stopStubbing();
        Application.Selector.setMock(productsSelectorMock);

        // When
        String selectedProductsNotFoundErrorMessage = new SelfSignUpServiceImpl().validateSelectedProductsUuids(request);

        // Then
        Assert.isTrue(String.isEmpty(selectedProductsNotFoundErrorMessage));
    }

}