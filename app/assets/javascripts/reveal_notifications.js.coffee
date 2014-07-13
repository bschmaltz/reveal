api_url="https://reveal-api.herokuapp.com"
#api_url="http://localhost:3001"
timeOutId = 0
$ ->
  $('.notification').on click: (e)->
    class_clicked = $(e.target).attr('class')
    if class_clicked!='post_avatar_image' and class_clicked!='post_username_link'
      window.location = "/posts/#{$(this).data().postid}"
  update_notfications()


update_notfications = ->
  if $('#auth_user_info').data().authenticated == true
    auth_token = $("#auth_user_info").data().token
    $.ajax "#{api_url}/reveal_notifications",
      type: 'GET'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      success: (data) ->
        notification_num = data.new_notifications.length
        old_notification_num = $('#notification-num').text()
        if old_notification_num == ""
          old_notification_num = 0
        else
          old_notification_num = parseInt(old_notification_num)
        if notification_num > old_notification_num and old_notification_num == 0
          $('#notification-icon-id').html("<i class=\"fi-flag\"></i>(<span id=\"notification-num\">#{notification_num}</span>)")
          $('#notification-icon-id').addClass("notification-icon-active")
        else if old_notification_num>0 and notification_num==0
          $('#notification-icon-id').html("<i class=\"fi-flag\"></i><span id=\"notification-num\"></span>")
          $('#notification-icon-id').attr('class', 'notification-icon')
        else if notification_num != old_notification_num
          $('#notification-num').text(notification_num)
      complete: ->
        timeOutId = setTimeout(update_notfications, 10000)

        