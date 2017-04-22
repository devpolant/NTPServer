
$(document).ready(function () {
    var token = getToken();
    $.ajax({
            url: "http://localhost:8090/dashboard/apps/list", 
            type:"POST",
            // headers: {
            //         'Authorization':'Bearer ' + token
            // },
            data: { 
                token: token 
            },
            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
            success:function(data){
                console.log(data);
                try {
                    if(!data.error) {
                        if (data.apps.length > 0) {
                            for (i = 0; i < data.apps.length; i++) {
                                var app = data.apps[i];
                                $('#apps-table-body').append('<tr><td>'+ app.id + '</td>'
                                    +'<td>'+ app.name + '</td>'
                                    +'<td>'+ app.social_group + '</td>'
                                    +'<td>'+ app.location + '</td>'
                                    +'<td>'+ app.status + '</td>'
                                    +'<td><a href="'+ '/dashboard/apps/' + app.id + '/info' +'" class="btn btn-info" role="button">View</a></td>');
                            }
                        } else {
                            $('#apps-table-body').append('<p style="margin:20px">You don\'t have apps yet</p>');
                        }
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
