public class TwilioQueueable implements Queueable, Database.AllowsCallouts{
    public String messageBody;
    public String recipient;

    public void execute(QueueableContext ctx) {
        TwilioService.sendText(recipient, messageBody);
    }
}