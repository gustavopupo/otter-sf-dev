public with sharing class Opportunities extends fflib_SObjects implements IOpportunities {

    public static final String PROSPECTING_STAGE_API_NAME = 'Prospecting';
    public static final String CLOSED_WON_STAGE_API_NAME = 'Closed Won';

    public static IOpportunities newInstance(List<Opportunity> recordList) {
        return (IOpportunities) Application.Domain.newInstance(recordList, Schema.Opportunity.SObjectType);
    }

    public Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList, Schema.Opportunity.SObjectType);
    }

    public void markAsClosedWon() {
        for (Opportunity opportunity : (List<Opportunity>) getRecords()) {
            opportunity.StageName = CLOSED_WON_STAGE_API_NAME;
        }
    }

    public void setPricebook(Id pricebook2Id) {
        for (Opportunity opportunity : (List<Opportunity>) getRecords()){
            opportunity.Pricebook2Id = pricebook2Id;
        }
    }

    public class Constructor implements fflib_IDomainConstructor {
        public fflib_SObjects construct(List<Object> objectList) {
            return new Opportunities((List<SObject>) objectList);
        }
    }

}