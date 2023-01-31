public class Application {

    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
                new List<SObjectType> {
                    Account.SObjectType,
                    Contact.SObjectType,
                    Product2.SObjectType,
                    Opportunity.SObjectType,
                    OpportunityLineItem.SObjectType });

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service = 
        new fflib_Application.ServiceFactory( 
            new Map<Type, Type> {
                    ILeadsService.class => LeadsServiceImpl.class,
                    IOpportunitiesService.class => OpportunitiesServiceImpl.class,
                    ISelfSignUpService.class => SelfSignUpServiceImpl.class });

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                    Account.SObjectType => AccountsSelector.class,
                    Lead.SObjectType => LeadsSelector.class,
                    LeadStatus.SObjectType => LeadStatusesSelector.class,
                    Pricebook2.SObjectType => PricebooksSelector.class,
                    PricebookEntry.SObjectType => PricebookEntriesSelector.class,
                    Product2.SObjectType => ProductsSelector.class });

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(
            Application.Selector,
            new Map<SObjectType, Type> {
                    Opportunity.SObjectType => Opportunities.Constructor.class });

}