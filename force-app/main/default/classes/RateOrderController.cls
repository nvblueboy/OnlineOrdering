public without sharing class RateOrderController {
    public String orderId {get;set;}
    public Order__c orderRec {get;set;}

    public Boolean needsRating {get;set;}

    public RateOrderController() {
        orderId = ApexPages.currentPage().getParameters().get('id');
        
        //Query for the order
        orderRec = [SELECT Id, Rating__c, Item__r.Name, Order_Number__c FROM Order__c WHERE Id = :orderId];

        if (orderRec.Rating__c == null) {
            needsRating = true;
        } else {
            needsRating = false;
        }
    }

    @RemoteAction
    public static void rateOrder(Id orderId, String rating) {
        Integer ratingVal = Integer.valueOf(rating);

        Order__c toUpdate = new Order__c(Id = orderId, Rating__c = ratingVal);
        update toUpdate;
    }
}