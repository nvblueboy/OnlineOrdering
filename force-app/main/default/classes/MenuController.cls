global class MenuController {
	public Event__c eventRec { get; set; }
	public List<Section__c> sections { get; set; }
	public string jsonData { get; set; }
    public Boolean orderingLock {get;set;}

	public MenuController() {
		String eventId = ApexPages.currentPage().getParameters().get('id');

        if(ApexPages.currentPage().getParameters().containsKey('lock')) {
            orderingLock = true;
        } else {
            orderingLock = false;
        }

		if (String.isBlank(eventId)) {
			System.debug('No Event found');
			return;
		}

		System.debug('Event ID: ' + eventId);

		eventRec = [SELECT Id, Name, Menu_Text__c, Menu_Header__c FROM Event__c WHERE Id = :eventId];

		sections = [
			SELECT
				Id,
				Name,
				(
					SELECT Id, Name, Description__c
					FROM Items__r
					WHERE Allow_Ordering__c = TRUE
                    ORDER BY Sort_Order__c ASC NULLS LAST
				)
			FROM Section__c
			WHERE Event__c = :eventRec.Id
		];

		jsonData = JSON.serialize(sections);
	}

	@RemoteAction
	global static Order__c submitOrder(
		Id itemId,
		String firstName,
		String lastName,
		String phoneNumber
	) {
		//First, find a Contact if they exist

		System.debug('itemId ' + itemId);
		System.debug('firstName ' + firstName);
		System.debug('lastName ' + lastName);
		System.debug('phoneNumber ' + phoneNumber);

		String cleanedNumber = phoneNumber.replaceAll('[^0-9]*', '');

		System.debug('cleanedNumber ' + cleanedNumber);

		Contact c;

		if (
			(!String.isBlank(firstName) && !String.isBlank(lastName)) ||
			!String.isBlank(phoneNumber)
		) {
			System.debug('Searching for Contact');
			List<Contact> contacts = new List<Contact>();

			if (phoneNumber != null) {
				System.debug('PhoneNumber != null');
				contacts = [
					SELECT Id, Name
					FROM Contact
					WHERE Cleaned_Phone_Number__c = :cleanedNumber
					ORDER BY CreatedDate ASC
				];
				System.debug(contacts);
			}

			if (contacts.size() == 0 && firstName != null && lastName != null) {
				contacts = [
					SELECT Id, Name
					FROM Contact
					WHERE FirstName LIKE :firstName AND LastName LIKE :lastName
					ORDER BY CreatedDate ASC
				];
			}

			if (contacts.size() == 0) {
				if (String.isBlank(firstName)) {
					firstName = 'Unknown';
				}

				if (String.isBlank(lastName)) {
					lastName = 'Unknown';
				}

				c = createContact(firstName, lastName, phoneNumber);
			} else {
				c = contacts[0];
			}

			System.debug(c);
		}

		Order__c newOrder = new Order__c(Item__c = itemId, Status__c = 'New');

		if (c != null) {
			newOrder.Contact__c = c.Id;
		}

		insert newOrder;

		Order__c loaded = [
			SELECT Id, Order_Number__c
			FROM Order__c
			WHERE Id = :newOrder.Id
		];

		if (phoneNumber != null) {
			phoneNumber = phoneNumber.replaceAll('[^0-9]*', '');
			System.debug(phoneNumber);
			TwilioService.sendTextFuture(
				'+1' + phoneNumber,
				'Thanks for ordering! Your order number is #' +
				String.valueOf(integer.valueOf(loaded.Order_Number__c)) +
				'.'
			);
		}

		return loaded;
	}

	private static Contact createContact(
		String firstName,
		String lastName,
		String phoneNumber
	) {
		Contact cont = new Contact();

		if (lastName != null) {
			cont.LastName = lastName;
		}
		if (firstName != null) {
			cont.FirstName = firstName;
		}
		if (phoneNumber != null) {
			cont.Phone = phoneNumber;
		}

		insert cont;
		return cont;
	}
}