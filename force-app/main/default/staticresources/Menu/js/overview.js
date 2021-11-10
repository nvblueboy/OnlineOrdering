$(document).ready(function() {
    //Set up the clock
    var d = new Date();
    $("#clock").text(d.toLocaleTimeString());
    setInterval(function() {
        
        var d = new Date();
        $("#clock").text(d.toLocaleTimeString());
    }, 500);

    setInterval(refreshData, 5000);
})