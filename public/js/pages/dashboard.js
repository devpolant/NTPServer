    $(document).ready(function () {
    var token = localStorage.getItem("access_token");
    console.log(token)
     $.ajax({
            url: "http://localhost:8090/dashboard", 
            type:"POST",
            headers: {
                    'Authorization':'Bearer ' + token
            },
            success:function(data){
                try {
                    if(!data.error) {
                        for (var i in data.menu_categories) {
                            var each = data.menu_categories[i];
                            $('#menu_tablist').append('<li role="presentation"><a id="'+each._id+'" onclick="selectCategory(\''+each._id+'\')" href="#">'+each.name+'</a></li>');
                        }
                        selectCategory(data.menu_categories[0]._id);
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
