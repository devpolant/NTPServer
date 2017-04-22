
$(document).ready(function () {
    var token = getToken();

    // Load info

    $.ajax({
        url:"http://localhost:8090/profile",
        type:"POST",
        data: { 
            token: token
        },
        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
        success:function(data){
            console.log(data);
            try {
                if(!data.error) {
                    var vendor = data.profile;
                    $("#inputLogin").val(vendor.login);
                    $("#inputEmail").val(vendor.email);
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
        var login = $("#inputLogin").val();
        var email = $("#inputEmail").val();
        $.ajax({
            url:"http://localhost:8090/profile/update",
            type:"POST",
            data: { 
                token: token,
                login: login,
                email: email
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
