$(document).ready(function() {
    $("#new_user form").on("ajax:error", function(event) {
        $(".has-error").empty();
        [data, status, xhr] = event.detail;
        Object.keys(data).forEach(function(key) {
            error = data[key][0];
            $("."+key).append("<strong class='help'><i class='fas fa-exclamation-triangle'></i> This " +error+"</strong></span>");
        });
    }).on("ajax:success", function(event) {
        $(".has-error").empty();
        $(".input").val('');
        $("#submit").removeClass("dark-orange").addClass("is-success").prop("disabled", true);
        $("#submit").val("Registered!");
        //refocus on the phone field for more submissions
        $("#user_phone").focus();
    });

    $(".input").on("keypress", function(event) {
        $("#submit").removeClass("is-success").addClass("dark-orange").prop("disabled", false);
        $("#submit").val("Send me a text");
    });

    $(".activate-modal").on("click", function(event) {
        $(".modal").addClass("is-active");
    });

    $(".modal-close").on("click", function() {
        $(".modal").removeClass("is-active");
    })

    $(".modal-background").not(".modal-content").on("click", function() {
        $(".modal").removeClass("is-active");
    });
});