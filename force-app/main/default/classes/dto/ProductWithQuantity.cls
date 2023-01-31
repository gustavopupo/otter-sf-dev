public class ProductWithQuantity {

    public Id productId;
    public Integer quantity;

    public ProductWithQuantity(Id productId, Integer quantity) {
        this.productId = productId;
        this.quantity = quantity;
    }
    
    /**
     * Implementation of hashCode and equals methods enable the usage of fflib_Match.eqList in tests
     */
    public Integer hashCode() {
        return (31 * String.valueOf(productId).hashCode()) ^ quantity;
    }

    /**
     * Implementation of hashCode and equals methods enable the usage of fflib_Match.eqList in tests
     */
    public Boolean equals(Object obj) {
        if (obj instanceof ProductWithQuantity) {
            ProductWithQuantity myObj = (ProductWithQuantity) obj;
            return (productId.equals(myObj.productId)) && (quantity == myObj.quantity);
        }
        return false;
    }

}