$(document).ready(function () {

    $("#submit_button").on("click", function () {
        var login_value = $("#inputLogin").val();
        var email_value = $("#inputEmail").val();
        var password_value = $("#inputPassword").val();
        var confirm_password_value = $("#confirmPassword").val();

        $.ajax({
            url:"http://localhost:8090/auth/signup",
            type:"POST",
            data:{ 
                "login": login_value, 
                "email" : email_value, 
                "password" : password_value, 
                "confirm_password": confirm_password_value 
            },
            success:function(data){
                console.log(data);
                try {
                    if(!data.error) {
						setToken(data.access_token);
                        window.location = '/dashboard';
                    } else {
                         // $("#alert_container").removeClass().addClass("alert alert-danger").text(data.message).show();
                    }
                } catch(err) {
					// $("#alert_container").removeClass().addClass("alert alert-danger").text(err.message).show();
                }
            },
            error:function(err) {
				console.log('Ошибка');
				console.log(err);
            }
        });

    });
});
