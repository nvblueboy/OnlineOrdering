public with sharing class TwilioService {
    

    public static void sendText(String target, String body) {
        HttpRequest req = new HttpRequest();
        Twilio_Settings__c settings = Twilio_Settings__c.getInstance();
        req.setEndpoint('callout:Twilio/Accounts/' + settings.Account_SID__c + '/Messages.json');
        req.setMethod('POST');

        string nondigits = '[^0-9]';

        target = target.replaceAll(nondigits,'');

        String toString = 'To=+1' + target;
        String fromString = 'From=' + settings.Twilio_Number__c;
        String bodyString = 'Body='+body;

        req.setBody(toString + '&' + fromString + '&' + bodyString);

        // Specify the required user name and password to access the endpoint
        // As well as the header and header information
        
        // Create a new http object to send the request object
        // A response object is generated as a result of the request  

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
    }


    public static void sendTextFuture(String target, String body) {
        TwilioQueueable q = new TwilioQueueable();
        q.messageBody = body;
        q.recipient = target;
        System.enqueueJob(q);
    }


}