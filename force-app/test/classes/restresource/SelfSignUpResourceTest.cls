@isTest
public class SelfSignUpResourceTest {

    @isTest
    static void callingRestResourceShouldReturnResponse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISelfSignUpService selfSignUpServiceMock = (ISelfSignUpService) mocks.mock(ISelfSignUpService.class);

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
        SelfSignUpResponse response = new SelfSignUpResponse();
        response.status = SelfSignUpResponse.StatusCode.NO_MATCHING_ACCOUNT_OR_LEAD_FOUND;
        RestRequest restRequest = new RestRequest();
        restRequest.requestBody = Blob.valueOf(JSON.serialize(request));
        RestResponse restResponse = new RestResponse();
        restRequest.requestURI = '/services/apexrest/self-sign-up';
        restRequest.httpMethod = 'POST';
        RestContext.request = restRequest;
        RestContext.response = restResponse;
        mocks.startStubbing();
        mocks.when(selfSignUpServiceMock.processSelfSignUp((SelfSignUpRequest) fflib_Match.anyObject())).thenReturn(response);
        mocks.stopStubbing();
        Application.Service.setMock(ISelfSignUpService.class, selfSignUpServiceMock);

        // When
        SelfSignUpResource.selfSignUp();

        // Then
        ((ISelfSignUpService) mocks.verify(selfSignUpServiceMock, 1)).processSelfSignUp((SelfSignUpRequest) fflib_Match.anyObject());
        response = (SelfSignUpResponse) JSON.deserialize(restResponse.responseBody.toString(), SelfSignUpResponse.class);
        Assert.areEqual(SelfSignUpResponse.StatusCode.NO_MATCHING_ACCOUNT_OR_LEAD_FOUND, response.status);
    }

}