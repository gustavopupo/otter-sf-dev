@RestResource(UrlMapping='/self-sign-up')
global with sharing class SelfSignUpResource {

    @HttpPost
    global static void selfSignUp() {
        String requestBody = RestContext.request.requestBody.toString();

        SelfSignUpRequest request = (SelfSignUpRequest) JSON.deserialize(requestBody, SelfSignUpRequest.class);
        SelfSignUpResponse response = SelfSignUpService.processSelfSignUp(request);

        RestContext.response.statusCode = SelfSignUpResponse.HTTP_STATUS_CODES_INDEXED_BY_DOMAIN_STATUS_CODES.get(response.status);
        RestContext.response.responseBody = Blob.valueOf(JSON.serializePretty(response, true));
    }

}