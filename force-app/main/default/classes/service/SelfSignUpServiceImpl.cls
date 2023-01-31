public class SelfSignUpServiceImpl implements ISelfSignUpService {

    public static final String PRICEBOOK_NAME_FOR_NEW_OPPORTUNITIES = 'Standard Price Book';

    private static final List<String> SELF_SIGN_UP_REQUEST_REQUIRED_FIELDS = new List<String> {
        'companyName',
        'firstName',
        'lastName'
    };

    /**
     * Attempts to match the request DTO to an existing Account or Lead. If an Account is found, no action is taken.
     * If a Lead is found, converts the Lead using an asynchronous job. If no Account or Lead is found, creates new
     * Account, Opportunity, and Contact records.
     * 
     * @param request DTO that contains the required data for the self sign-up process.
     */
    public SelfSignUpResponse processSelfSignUp(SelfSignUpRequest request) {
        // Checks if the request contains the fields listed in SELF_SIGN_UP_REQUEST_REQUIRED_FIELDS
        String requiredFieldsErrorMessage = validateRequiredFields(request);
        if (String.isNotEmpty(requiredFieldsErrorMessage)) {
            return new SelfSignUpResponseBuilder()
                .setStatus(SelfSignUpResponse.StatusCode.MISSING_REQUIRED_FIELDS)
                .setMessage(requiredFieldsErrorMessage)
                .build();
        }

        // Checks if the UUIDs of the selected products can be matched to existing Product2 records
        String selectedProductsNotFoundErrorMessage = validateSelectedProductsUuids(request);
        if (String.isNotEmpty(selectedProductsNotFoundErrorMessage)) {
            return new SelfSignUpResponseBuilder()
                .setStatus(SelfSignUpResponse.StatusCode.SELECTED_PRODUCT_UUID_NOT_FOUND)
                .setMessage(selectedProductsNotFoundErrorMessage)
                .build();
        }

        // If there is an Account that matches the Company Name from the request, then do not take any action
        List<Account> accounts = AccountsSelector.newInstance().selectByName(new Set<String>{ request.companyName });
        if (!accounts.isEmpty()) {
            return new SelfSignUpResponseBuilder()
                .setStatus(SelfSignUpResponse.StatusCode.MATCHING_ACCOUNT_ALREADY_EXISTS)
                .setMessage('An account named \'' + accounts[0].Name + '\' already exists.')
                .build();
        }

        // If there is a Lead that matches the Company Name from the request, then convert the Lead using an asynchronous job
        List<Lead> leads = LeadsSelector.newInstance().selectByCompany(new Set<String>{ request.companyName });
        if (!leads.isEmpty()) {
            List<ProductWithQuantity> products = getProductsForRequest(request);
            Id conversionJobId = LeadsService.enqueueConversionJob(leads[0], products);

            // The job ID is returned in the response so that the caller can check the job status
            return new SelfSignUpResponseBuilder()
                .setStatus(SelfSignUpResponse.StatusCode.EXISTING_LEAD_QUEUED_FOR_CONVERSION)
                .setMessage('Found an existing lead named \'' + leads[0].Name + '\' and added the conversion asynchronous job to the queue.')
                .setConversionJobId(conversionJobId)
                .build();
        }

        // If no Lead or Account is found that matches the Company Name, then create new Account, Opportunity, and Contact records
        createRecordsForSelfSignUp(request);

        return new SelfSignUpResponseBuilder()
            .setStatus(SelfSignUpResponse.StatusCode.NO_MATCHING_ACCOUNT_OR_LEAD_FOUND)
            .setMessage('No existing account or lead records were found, therefore new Account, Opportunity, and Contact records were created.')
            .build();
    }

    /**
     * Checks if the request contains the fields listed in SELF_SIGN_UP_REQUEST_REQUIRED_FIELDS.
     * 
     * @param request DTO that contains the required data for the self sign-up process.
     */
    @TestVisible
    private String validateRequiredFields(SelfSignUpRequest request) {
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(request, true));
        List<String> missingFields = new List<String>();

        for (String requiredField : SELF_SIGN_UP_REQUEST_REQUIRED_FIELDS) {
            if (!requestMap.containsKey(requiredField)) {
                missingFields.add(requiredField);
            }
        }

        if (missingFields.isEmpty()) {
            return '';
        }

        return 'One or more required fields are missing: ' + missingFields;
    }

    /**
     * Checks if the UUIDs of the selected products can be matched to existing Product2 records.
     * 
     * @param request DTO that contains the required data for the self sign-up process.
     */
    @TestVisible
    private String validateSelectedProductsUuids(SelfSignUpRequest request) {
        if (request.selectedProducts == null || request.selectedProducts.isEmpty()) {
            return 'Request does not contain any products under the \'selectedProducts\' key.';
        }

        Set<String> uuids = new Set<String>();
        for (SelfSignUpRequest.SelectedProduct selectedProduct : request.selectedProducts) {
            uuids.add(selectedProduct.uuid);
        }

        List<Product2> products = ProductsSelector.newInstance().selectByUuid(uuids);
        Set<String> uuidsFromDatabase = new Set<String>();
        for (Product2 product : products) {
            uuidsFromDatabase.add(product.Uuid__c);
        }

        Set<String> uuidsNotFound = new Set<String>();
        for (String uuid : uuids) {
            if (!uuidsFromDatabase.contains(uuid)) {
                uuidsNotFound.add(uuid);
            }
        }

        if (uuidsNotFound.isEmpty()) {
            return '';
        }

        return 'One or more UUIDs could not be matched to existing Product records: ' + uuidsNotFound;
    }

    /**
     * Creates new Account, Contact, Opportunity, and Opportunity Line Item records based on the data provided
     * in the request.
     * 
     * @param request DTO that contains the required data for the self sign-up process.
     */
    private void createRecordsForSelfSignUp(SelfSignUpRequest request) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();

        Account account = createAccount(request, uow);
        Contact contact = createContact(request, account, uow);
        Opportunity opportunity = createOpportunity(request, account, contact, uow);

        uow.commitWork();

        List<ProductWithQuantity> products = getProductsForRequest(request);
        OpportunitiesService.createOpportunityLineItems(opportunity.Id, opportunity.Pricebook2Id, products);
        OpportunitiesService.markAsClosedWon(new Set<Id>{ opportunity.Id });
    }

    /**
     * Selects the IDs from Product2 records based on the product UUIDs provided in the request. The returned
     * list contains the Product2 IDs and the quantities specified in the request for each product.
     * 
     * @param request DTO that contains the required data for the self sign-up process.
     */
    private List<ProductWithQuantity> getProductsForRequest(SelfSignUpRequest request) {
        Map<String, Integer> productQuantitiesIndexedByUuid = new Map<String, Integer>();

        // Get UUIds and quantities from the request
        for (SelfSignUpRequest.SelectedProduct selectedProduct : request.selectedProducts) {
            productQuantitiesIndexedByUuid.put(selectedProduct.uuid, selectedProduct.quantity);
        }

        List<Product2> products = ProductsSelector.newInstance().selectByUuid(productQuantitiesIndexedByUuid.keySet());

        // ProductWithQuantity contains the Product2 ID and the quantity specified in the request
        List<ProductWithQuantity> productsWithQuantities = new List<ProductWithQuantity>();

        for (Product2 product : products) {
            ProductWithQuantity productWithQuantity = 
                new ProductWithQuantity(product.Id, productQuantitiesIndexedByUuid.get(product.Uuid__c));

            productsWithQuantities.add(productWithQuantity);
        }

        return productsWithQuantities;
    }

    private Account createAccount(SelfSignUpRequest request, fflib_ISObjectUnitOfWork uow) {
        Account newAccount = new Account();
        newAccount.Name = request.companyName;
        newAccount.Phone = request.phone;
        newAccount.BillingCity = request.address.city;
        newAccount.BillingCountry = request.address.country;
        newAccount.BillingPostalCode = request.address.postalCode;
        newAccount.BillingState = request.address.state;
        newAccount.BillingStreet = request.address.street;

        uow.registerNew(newAccount);

        return newAccount;
    }

    private Contact createContact(SelfSignUpRequest request, Account account, fflib_ISObjectUnitOfWork uow) {
        Contact newContact = new Contact();
        newContact.FirstName = request.firstName;
        newContact.LastName = request.lastName;
        newContact.Email = request.email;
        newContact.Phone = request.phone;
        
        uow.registerNew(newContact, Contact.AccountId, account);

        return newContact;
    }

    private Opportunity createOpportunity(SelfSignUpRequest request, Account account, Contact contact, fflib_ISObjectUnitOfWork uow) {
        List<Pricebook2> pricebooks = PricebooksSelector.newInstance().selectByName(new Set<String>{ PRICEBOOK_NAME_FOR_NEW_OPPORTUNITIES });

        if (pricebooks.isEmpty()) {
            throw new SelfSignUpServiceException('Could not find a Pricebook named \'' + PRICEBOOK_NAME_FOR_NEW_OPPORTUNITIES + '\'.');
        }

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = request.companyName;
        newOpportunity.StageName = Opportunities.PROSPECTING_STAGE_API_NAME;
        newOpportunity.CloseDate = System.today();
        newOpportunity.Pricebook2Id = pricebooks[0].Id;

        uow.registerRelationship(newOpportunity, Opportunity.AccountId, account);
        uow.registerRelationship(newOpportunity, Opportunity.ContactId, contact);
        uow.registerNew(newOpportunity);

        return newOpportunity;
    }

    public class SelfSignUpServiceException extends Exception {}

}