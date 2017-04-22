
$(document).ready(function () {
    var token = getToken();

    // Load app info
    var appId = $("#inputAppId").val();

    $.ajax({
        url:"http://localhost:8090/dashboard/apps/" + appId + "/info",
        type:"POST",
        data: { 
            token: token
        },
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        success:function(data){
            console.log(data);
            try {
                if(!data.error) {
                    var app = data.app;
                    console.log("App: " + app.name);
                    $("#inputAppId").val(app.id);
                    $("#inputAppName").val(app.name);
                    $("#inputLocation").val(app.location);
                    $("#inputGroupName").val(app.social_group);
                } 
            } catch(err) {
                alert(err.message);
            }
        },
        error:function(err) {
            console.log('Ошибка');
            console.log(err);
        }
    });

    // Update app info

    $("#app-send-button").on("click", function () {
        var appId = $("#inputAppId").val();
        var name = $("#inputAppName").val();
        var location = $("#inputLocation").val();
        var socialGroup = $("#inputGroupName").val();
        $.ajax({
            url:"http://localhost:8090/dashboard/apps/" + appId + "/update",
            type:"POST",
            data: { 
                token: token,
                name: name,
                location: location,
                social_group: socialGroup
            },
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            success:function(data){
                console.log(data);
                try {
                    if(!data.error) {
                        window.location = '/dashboard';
                    } 
                } catch(err) {
                    alert(err.message);
                }
            },
            error:function(err) {
                console.log('Ошибка');
                console.log(err);
            }
        });

    });
});
