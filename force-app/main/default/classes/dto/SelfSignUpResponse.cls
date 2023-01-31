public with sharing class SelfSignUpResponse {

    public enum StatusCode {
        MATCHING_ACCOUNT_ALREADY_EXISTS,
        NO_MATCHING_ACCOUNT_OR_LEAD_FOUND,
        EXISTING_LEAD_QUEUED_FOR_CONVERSION,
        MISSING_REQUIRED_FIELDS,
        SELECTED_PRODUCT_UUID_NOT_FOUND
    }

    public static final Map<StatusCode, Integer> HTTP_STATUS_CODES_INDEXED_BY_DOMAIN_STATUS_CODES =
        new Map<StatusCode, Integer> {
            StatusCode.MATCHING_ACCOUNT_ALREADY_EXISTS => 200, // OK
            StatusCode.NO_MATCHING_ACCOUNT_OR_LEAD_FOUND => 201, // Created
            StatusCode.EXISTING_LEAD_QUEUED_FOR_CONVERSION => 202, // Accepted
            StatusCode.MISSING_REQUIRED_FIELDS => 400, // Bad Request
            StatusCode.SELECTED_PRODUCT_UUID_NOT_FOUND => 400 // Bad Request
        };

    public StatusCode status {get; set;}
    public String message {get; set;}
    public Id conversionJobId {get; set;}

    public SelfSignUpResponse() {
    }

    public SelfSignUpResponse(StatusCode status, String message, Id conversionJobId) {
        this.status = status;
        this.message = message;
        this.conversionJobId = conversionJobId;
    }

}