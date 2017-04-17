function getCookie(name) {
    return localStorage.getItem("access_token");
}

$(document).ready(function () {

    $("#login_submit").on("click", function () {

        var email_value = $("#email").val();
        var password_value = $("#password").val();

        $.ajax({
            url:"http://localhost:8090/auth/login",
            type:"POST",
            data:{ "email" : email_value, "password" : password_value },
            success:function(data){
                try {
                    if(!data.error) {
                        alert(data);
						// document.cookie = "access_token=" + data.access_token;
						localStorage.setItem("access_token", data.access_token)
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
