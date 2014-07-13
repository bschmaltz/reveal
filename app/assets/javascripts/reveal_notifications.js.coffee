api_url="https://reveal-api.herokuapp.com"
#api_url="http://localhost:3001"
$ ->
  $('.notification').on click: (e)->
    class_clicked = $(e.target).attr('class')
    if class_clicked!='post_avatar_image' and class_clicked!='post_username_link'
      window.location = "/posts/#{$(this).data().post_id}"