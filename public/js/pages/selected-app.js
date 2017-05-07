
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
                    $("#inputAppId").val(app.id);
                    $("#inputAppName").val(app.name);
                    $("#inputLocation").val(app.location);
                    $("#inputGroupName").val(app.social_group);

                    if (data.categories.length > 0) {
                        for (i = 0; i < data.categories.length; i++) {
                            var category = data.categories[i];
                            $('#categories-table-body').append('<tr><td>'+ category.id + '</td>'
                                +'<td>'+ category.name + '</td>'
                                +'<td>'+ category.social_group + '</td>'
                                +'<td>'+ category.social_network_name + '</td>'
                                +'<td>'+ (category.filter_query != null ? category.filter_query : "-") + '</td>');
                        }
                    } else {
                        $('#categories-table-body').append('<p style="margin:20px">You don\'t have apps yet</p>');
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

    // Create category

    $("#category-send-button").on("click", function () {
        var appId = $("#inputAppId").val();
        var categoryName = $("#inputCategoryName").val();
        var socialGroup = $("#inputCategoryGroupName").val();
        var filterQuery = $("#inputFilterQuery").val();
        $.ajax({
            url:"http://localhost:8090/dashboard/apps/" + appId + "/category/create",
            type:"POST",
            data: { 
                token: token,
                name: categoryName,
                social_group: socialGroup,
                social_network_id: 1,       // Constant at now
                filter_query: filterQuery
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
