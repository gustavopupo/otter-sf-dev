public interface ILeadsSelector extends fflib_ISObjectSelector {
    List<Lead> selectById(Set<Id> leadIds);
    List<Lead> selectByCompany(Set<String> companies);
}