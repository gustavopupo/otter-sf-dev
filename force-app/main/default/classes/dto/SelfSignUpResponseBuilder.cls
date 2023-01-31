public class SelfSignUpResponseBuilder {

    private SelfSignUpResponse.StatusCode status;
    private String message;
    private Id conversionJobId;

    public SelfSignUpResponseBuilder setStatus(SelfSignUpResponse.StatusCode status) {
        this.status = status;
        return this;
    }

    public SelfSignUpResponseBuilder setMessage(String message) {
        this.message = message;
        return this;
    }

    public SelfSignUpResponseBuilder setConversionJobId(Id conversionJobId) {
        this.conversionJobId = conversionJobId;
        return this;
    }

    public SelfSignUpResponse build() {
        return new SelfSignUpResponse(status, message, conversionJobId);
    }

}