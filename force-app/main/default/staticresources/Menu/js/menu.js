var mode = "view";
var selectedItemId = '';

function clickItem(itemId) {

    if (locked) {
        return;
    }
    
    // console.log(itemId);
    selectedItemId = itemId;
    mode = "order";

    document.getElementById("order").classList.remove("hide");

    //Get data to display on the page so they can be sure of what they're ordering.
    // console.log(jsonData);

    var selectedItem = null;

    for (var section of jsonData) {
        for (var item of section.Items__r.records) {
            if (item.Id == itemId) {
                selectedItem = item;
                break;
            }
        }
    }

    console.log(selectedItem);

    document.getElementById("order_itemName").innerText = selectedItem.Name;
    document.getElementById("order_itemDescription").innerText = selectedItem.Description__c;

}

function closeMenu() {
    document.getElementById("order").classList.add("hide");
}

document.getElementById('phoneInput').addEventListener('input', function (e) {
    var x = e.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
    e.target.value = !x[2] ? x[1] : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '');
});

function submit() {
    var firstName = document.getElementById("firstInput").value;
    var lastName = document.getElementById("lastInput").value;
    var phone = document.getElementById("phoneInput").value;
    document.getElementById("spinner").classList.remove("hide");

    Visualforce.remoting.Manager.invokeAction(
        orderRemote,
        selectedItemId,
        firstName,
        lastName,
        phone,
        function(result, event) {
            console.log(result);
            if (result != null && result.Id != null) {
                var msg = 'Thanks for ordering! Your Order Number is #' + Number(result.Order_Number__c) + '. You can close this page or refresh to order again!';
                document.getElementById("confirm").innerHTML = msg;
                document.getElementById("confirm").classList.remove("hide");
            }
        }
    );
}