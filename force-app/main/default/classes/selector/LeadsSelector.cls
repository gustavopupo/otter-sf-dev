public class LeadsSelector extends fflib_SObjectSelector implements ILeadsSelector {

    public static ILeadsSelector newInstance() {
        return (ILeadsSelector) Application.Selector.newInstance(Lead.SObjectType);
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Lead.Id,
            Lead.Name,
            Lead.Company,
            Lead.ConvertedOpportunityId
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Lead.SObjectType;
    }

    public List<Lead> selectById(Set<Id> leadIds) {
        return (List<Lead>) selectSObjectsById(leadIds);
    }

    public List<Lead> selectByCompany(Set<String> companies) {
        return (List<Lead>) Database.query(
            newQueryFactory()
                .setCondition('Company IN :companies')
                .toSOQL()
        );
    }

}