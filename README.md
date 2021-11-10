# Online Ordering
A Salesforce-based app to facilitate online ordering, with SMS support. Created for a birthday party in 2021.

## Objects
#### Event
Stores the basic information for the event, including the header of the menu.
#### Section
Stores information for one section of the menu. When Managing Orders, you can filter orders by section. On the overview page, each section is represented separately.
#### Item
Stores the item in a section, it's status, and it's recipe (which displays when managing orders)
#### Order
Ties item to a Contact, contains the rating that gets rolled up to the section.
#### Site Settings (Custom Setting)
Stores the base URL of the site, used in the Event record page and on text messages sent out.
#### Twilio Settings (Custom Setting)
Stores information needed to connect to the Twilio API for sending texts.
