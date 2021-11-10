public class ManageOrdersController {
    public Event__c eventRec { get; set; }
    public List<Section__c> sections { get; set; }
    public List<SelectOption> sectionOptions { get; set; }
    public List<Order__c> openOrders { get; set; }

    public string sectionFilter { get; set; }

    public ManageOrdersController() {
        sectionFilter = '';
        String eventId = ApexPages.currentPage().getParameters().get('id');

        if (String.isBlank(eventId)) {
            System.debug('No Event found');
            return;
        }

        System.debug('Event ID: ' + eventId);

        eventRec = [SELECT Id, Name FROM Event__c WHERE Id = :eventId];
        sections = [
            SELECT Id, Name
            FROM Section__c
            WHERE Event__c = :eventRec.Id
        ];

        sectionOptions = new List<SelectOption>{
            new SelectOption('', 'All Orders')
        };

        for (Section__c section : sections) {
            sectionOptions.add(new SelectOption(section.Id, section.Name));
        }

        queryOpenOrders();
    }

    void queryOpenOrders() {
        if (String.isBlank(sectionFilter)) {
            openOrders = [
                SELECT
                    Id,
                    Order_Number__c,
                    Contact__r.Name,
                    Item__r.Name,
                    Item__r.Section__c,
                    Status__c,
                    Item__r.Recipe__c
                FROM Order__c
                WHERE Event__c = :eventRec.Id AND Status__c = 'New'
                ORDER BY CreatedDate ASC
            ];
        } else {
            openOrders = [
                SELECT
                    Id,
                    Order_Number__c,
                    Contact__r.Name,
                    Item__r.Name,
                    Item__r.Section__c,
                    Status__c,
                    Item__r.Recipe__c
                FROM Order__c
                WHERE
                    Event__c = :eventRec.Id
                    AND Item__r.Section__c = :sectionFilter
                    AND Status__c = 'New'
                ORDER BY CreatedDate ASC
            ];
        }
    }

    public Pagereference refreshList() {
        queryOpenOrders();
        return null;
    }

    @RemoteAction
    public static Order__c closeOrder(Id orderId) {
        Order__c order = new Order__c(Id = orderId, Status__c = 'Ready');
        update order;

        //If the order has a contact, get it's phone number and text it
        Order__c loadedOrder = [
            SELECT Id, Contact__r.Phone, Order_Number__c
            FROM Order__c
            WHERE Id = :orderId
        ];

        if (loadedOrder.Contact__r.Phone != null) {
            String phoneNumber = loadedOrder.Contact__r.Phone.replaceAll(
                '[^0-9]*',
                ''
            );
            System.debug(phoneNumber);
            TwilioService.sendTextFuture(
                '+1' + phoneNumber,
                ' Order number #' +
                String.valueOf(integer.valueOf(loadedOrder.Order_Number__c)) +
                ' is ready!\nVisit ' +
                Site_Settings__c.getInstance().Site_URL_Base__c + '/RateOrder?id=' + loadedOrder.Id +' to rate this order.'

            );
        }

        return order;
    }

    @RemoteAction
    public static void markOutOfStock(Id orderId) {
        //Use the order to get the item record
        Item__c item = [
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Status__c,
                        Contact__c,
                        Contact__r.Cleaned_Phone_Number__c
                    FROM Orders__r
                    WHERE Status__c = 'New'
                )
            FROM Item__c
            WHERE Id IN (SELECT Item__c FROM Order__c WHERE Id = :orderId)
            LIMIT 1
        ];

        //Iterate over the existing orders and text that contact that we're out.

        String msg =
            'Sorry! The ' +
            item.Name +
            ' is now Out of Stock. Please visit the menu to order another item.';

        for (Order__c order : item.Orders__r) {
            TwilioService.sendTextFuture(
                order.Contact__r.Cleaned_Phone_Number__c,
                msg
            );
            order.Status__c = 'Out of Stock';
        }

        Item__c toUpdate = new Item__c(
            Id = item.Id,
            Status__c = 'Out of Stock'
        );
        update toUpdate;

        update item.Orders__r;
    }
}