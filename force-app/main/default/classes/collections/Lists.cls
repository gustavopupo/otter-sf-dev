public class Lists {

    public static List<SObject> sObjectsFromIdSet(Set<Id> ids, Schema.SObjectType sObjectType) {
        List<SObject> newSObjects = new List<SObject>();

        for(Id id : ids) {
            SObject newSObject = sObjectType.newSObject(id);
            newSObjects.add(newSObject);
        }

        return newSObjects;
    }

}