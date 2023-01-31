public class LeadStatusesSelector extends fflib_SObjectSelector implements ILeadStatusesSelector {

    public static ILeadStatusesSelector newInstance() {
        return (ILeadStatusesSelector) Application.Selector.newInstance(LeadStatus.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            LeadStatus.Id,
            LeadStatus.MasterLabel
        };
    }

    public Schema.SObjectType getSObjectType() {
        return LeadStatus.SObjectType;
    }

    public LeadStatus selectConvertedStatus() {
        return (LeadStatus) Database.query(
            newQueryFactory()
                .setCondition('IsConverted = true')
                .setLimit(1)
                .toSOQL()
        );
    }

}