function setToggle() {
    $(".orderHeader").click(function(event) {
        event.stopPropagation();
        event.target.parentElement.classList.toggle("open");
    });
    
    $(".orderHeader .expandIcon i").click(function(event) {
        event.target.parentElement.parentElement.parentElement.parentElement.classList.toggle("open");
    });
    
    $(".orderHeader .orderHeaderText").click(function(event) {
        event.target.parentElement.parentElement.classList.toggle("open");
    });
    
}


function outOfStock(orderId) {
    console.log(orderId);

    if (!confirm("Are you sure you want to mark this out of stock?")) {
        return;
    }

    Visualforce.remoting.Manager.invokeAction(
        outRemote,
        orderId,
        function(result, event) {

            refreshList();

        }
    )
}


$(document).ready(function() {
    setToggle();
})

function finishOrder(orderId) {
    console.log(orderId);

    Visualforce.remoting.Manager.invokeAction(
        closeRemote,
        orderId,
        function(result, event) {
            console.log(result);

            if (result) {
                refreshList();
            }
        }
    )
}