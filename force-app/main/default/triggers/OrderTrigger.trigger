trigger OrderTrigger on Order__c (before insert, before update) {

    //Bad practice!!!
    Datetime dt = Datetime.now();
    Long d = dt.getTime();

    if (Trigger.isInsert) {
        for (Order__c order : Trigger.new) {
            order.Order_Placed__c = d;
        }
    }

    if (Trigger.isUpdate) {
        for (Order__c newOrder : Trigger.new) {
            Order__c oldOrder = Trigger.oldMap.get(newOrder.Id);

            if (newOrder.Status__c != oldOrder.Status__c && newOrder.Status__c == 'Ready') {
                newOrder.Order_Finished__c = d;
            }
        }
    }

}