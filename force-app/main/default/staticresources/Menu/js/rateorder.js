$(document).ready(function() {
    $("#submitButton").click(function(event) {
        var value = $('input[name="rating"]:checked').val();

        console.log(value);

        if (!value) {
            $("#selectError").removeClass("hideError");
            return;
        }

        $("#spinner").removeClass("hide");


        Visualforce.remoting.Manager.invokeAction(
            submitRemote,
            orderId,
            value,
            function(result, event) {
                console.log(result);

                $("#confirm").removeClass("hide");

            }
        );

        
    })
});