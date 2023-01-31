public without sharing class SelfSignUpService {

    public static SelfSignUpResponse processSelfSignUp(SelfSignUpRequest request) {
        return service().processSelfSignUp(request);
    }

    private static ISelfSignUpService service() {
        return (ISelfSignUpService) Application.Service.newInstance(ISelfSignUpService.class);
    }

}