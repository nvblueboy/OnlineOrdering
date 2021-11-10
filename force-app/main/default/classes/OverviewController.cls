public class OverviewController {
	public Event__c eventRecord { get; set; }
	public List<PageSection> sections { get; set; }

	public OverviewController() {
		String eventId = ApexPages.currentPage().getParameters().get('id');

		eventRecord = [SELECT Id, Name FROM Event__c WHERE Id = :eventId];

		createSections();
	}

    public void createSections() {
        List<Section__c> sectionRecords = [
			SELECT Id, Name, Average_Rating__c, (SELECT Id, Name FROM Items__r ORDER BY Average_Rating__c DESC NULLS LAST), (SELECT Id, Name, Item__r.Name, Order_Number__c, Contact__r.Name, Order_Placed__c, Order_Finished__c, Status__c FROM Orders__r ORDER BY CreatedDate ASC)
			FROM Section__c
			WHERE Event__c = :eventRecord.Id
		];


        sections = new List<PageSection>();

        for (Section__c sectionRecord : sectionRecords) {
            PageSection newSection = new PageSection();
            newSection.sectionRecord = sectionRecord;


            for (Order__c order : sectionRecord.Orders__r) {
                newSection.totalOrders++;

                if (order.Status__c == 'New') {    
                    newSection.newOrders.add(new OrderObj(order));
                } else {
                    newSection.completeOrders++;

                    if (order.Order_Finished__c != null && order.Order_Placed__c != null) {
                        newSection.totalTime += (Long)(order.Order_Finished__c - order.Order_Placed__c);
                        newSection.finishedCount++;
                    }
                }
                
            }

            if (newSection.finishedCount > 0) {
                newSection.averageTime = Utils.formatTime(newSection.totalTime / newSection.finishedCount);
            } else {
                newSection.averageTime = 'N/A';
            }

            sections.add(newSection);
        }
    }

    public class PageSection {
        public Section__c sectionRecord {get;set;}
        public List<OrderObj> newOrders {get;set;}
        public Integer totalOrders {get;set;}
        public Integer completeOrders{get;set;}

        public Long totalTime;
        public Integer finishedCount;
        public String averageTime {get;set;}

        public PageSection() {
            newOrders = new List<OrderObj>();
            totalOrders = 0;
            completeOrders = 0;
            totalTime = 0;
            finishedCount = 0;
        }
    }

    public class OrderObj {
        public Order__c orderRecord {get;set;}
        public Item__c itemRecord {get;set;}
        public Contact contactRecord {get;set;}
        public String timeInFlight {get;set;}

        public OrderObj(Order__c record) {
            orderRecord = record;
            itemRecord = record.Item__r;
            contactRecord = record.Contact__r;

            timeInFlight = getTimeInFlight((Long)orderRecord.Order_Placed__c);

        }

        public String getTimeInFlight(Long startTime) {
            Long timeBetween = Datetime.now().getTime() - startTime;

            return Utils.formatTime(timeBetween);
        }
    }

}