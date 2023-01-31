public class SelfSignUpRequest {

    public String companyName {get; set;}
    public String email {get; set;}
    public String phone {get; set;}
    public List<SelfSignUpRequest.SelectedProduct> selectedProducts {get; set;}
    public SelfSignUpRequest.Address address {get; set;}
    public String firstName {get; set;}
    public String lastName {get; set;}

    public SelfSignUpRequest() {}

    public class SelectedProduct {
        public String uuid {get; set;}
        public Integer quantity {get; set;}
    }

    public class Address {
        public String city {get; set;}
        public String country {get; set;}
        public String postalCode {get; set;}
        public String state {get; set;}
        public String street {get; set;}
    }

}