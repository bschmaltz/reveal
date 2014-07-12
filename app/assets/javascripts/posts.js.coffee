api_url="https://reveal-api.herokuapp.com"
#api_url="http://localhost:3001"
post_page = ''
location = null
popular_page_num=0
popular_orig_request_time=null
$ ->
  if $('#page_info').data().controller == 'posts'
    post_page = $('#page_info').data().action
    if post_page == 'index_location' or post_page == 'new'
      setup_location()
    if post_page == 'index_popular'
      popular_orig_request_time= $('.posts').eq(0).data().requesttime
  $(document).scroll ->
    try_scroll_load_posts()
  rebind_posts()


rebind_posts = ->
  $('#reveal-switch-input').on click: (e)->
    e.preventDefault()
    e.stopPropagation()
    reveal_switch($(this))
    
  $('.delete_post').on click: (e)->
    e.stopPropagation()
    delete_post($(this))

  $('.post_watch').on click: (e)->
    e.stopPropagation()
    post_watch($(this))

  $('.post_ignore').on click: (e)->
    e.stopPropagation()
    post_ignore($(this))

  $('.post_listing').on click: (e)->
    class_clicked = $(e.target).attr('class')
    if class_clicked!='post_avatar_image' and class_clicked!='post_username_link' and class_clicked!='watch_user_link'
      view_post($(this))


view_post = (post)->
  id = post.data().id
  window.location = "/posts/#{id}"


try_scroll_load_posts = ->
  if element_in_scroll($('#feed_end'))
    load_posts()

load_posts = ->
  $(document).unbind('scroll')
  last_post = $('.post').last()
  url=''
  if post_page=='index'
    url = "#{api_url}/posts/index/#{last_post.data().id}"
  else if post_page=='index_followed'
    if last_post.data().itemtype=='watch'
      url="#{api_url}/posts/index_followed_posts?last_vote_id=#{last_post.data().voteid}"
    else
      url="#{api_url}/posts/index_followed_posts?last_post_id=#{last_post.data().id}"
  else if post_page=='index_location'
    if $('.post')[0]
      url = "#{api_url}/posts/index_by_location?last_post_id=#{last_post.data().id}&latitude=#{location.latitude}&longitude=#{location.longitude}"
    else
      url = "#{api_url}/posts/index_by_location?latitude=#{location.latitude}&longitude=#{location.longitude}"
  else
    popular_page_num=popular_page_num+1
    url = "#{api_url}/posts/index_popular?page=#{popular_page_num}&orig_request_time=#{popular_orig_request_time}"
  auth_token = $("#auth_user_info").data().token
  user_id = $("#auth_user_info").data().id
  $.ajax url,
    type: 'GET'
    contentType: 'application/json'
    beforeSend: (request) ->
      $('.ajax_loader').show()
      request.setRequestHeader("Authorization", "Token token=#{auth_token}")
    error: ->
      $('.ajax_loader').hide()
      alert('posts failed to load')
    success: (data) ->
      $('.ajax_loader').hide()
      if data.length == 0
        $('.posts').after('<div id="end_of_posts">You\'ve reached the end of the feed</div>')
      else
        for post in data
          username = ""
          post_vote = ""
          post_data = "data-id=#{post.id}  data-itemtype=\"#{post.item_type}\" data-voteid=\"#{post.vote_id}\""
          vote_data = "data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-watchstat=\"#{post.watch_stat}\" data-ignorestat=\"#{post.ignore_stat}\""
          post_avatar = "<div class=\"small-2 column post_avatar_div\"><a class=\"post_avatar_link\" href=\"/users/#{post.user_id}\"><img src=\""+post.avatar_thumb+"\" class=\"post_avatar_image\"></a></div>"
          watch_info = ""

          if !post.revealed and post.current_user_is_poster
            username = "<div class=\"row post_username\">Anonymous (Me)</div>"
          else if !post.revealed
            username = "<div class=\"row post_username\">Anonymous</div>"
          else
            username ="<div class=\"row post_username\"><a class=\"post_username_link\" href=\"/users/#{post.user_id}\">#{post.username}</a></div>"
          
          if post.current_user_is_poster
            post_vote = "<div class=\"row post_vote\" #{vote_data}><span class=\"post_watch\"><i class=\"fi-eye\"></i> #{post.watch_stat}</span><span class=\"post_ignore\"><i class=\"fi-dislike\"></i> #{post.ignore_stat}</span></div>"
          else
            if post.current_user_vote == 'watch'
              post_vote = "<div class=\"row post_vote\" #{vote_data}><span class=\"post_watch bold\"><i class=\"fi-eye\"></i> #{post.watch_stat}</span><span class=\"post_ignore\"><i class=\"fi-dislike\"></i> #{post.ignore_stat}</span></div>"
            else if post.current_user_vote == 'ignore'
              post_vote = "<div class=\"row post_vote\" #{vote_data}><span class=\"post_watch\"><i class=\"fi-eye\"></i> #{post.watch_stat}</span><span class=\"post_ignore bold\"><i class=\"fi-dislike\"></i> #{post.ignore_stat}</span></div>"
            else
              post_vote = "<div class=\"row post_vote\" #{vote_data}><span class=\"post_watch\"><i class=\"fi-eye\"></i> #{post.watch_stat}</span><span class=\"post_ignore\"><i class=\"fi-dislike\"></i> #{post.ignore_stat}</span></div>"

          if post.item_type == 'watch'
            watch_info = "<div class=\"row watch_info\">Watched by <a class=\"watch_user_link\" href=\"users/#{post.followed_user_id}\">#{post.followed_username}</a></div>"

          $('.posts').append("<li #{post_data} class=\"row post post_listing #{post.id}\">#{post_avatar}<div class=\"small-10 column non-avatar-content\">#{username}<div class=\"row post_content\">#{post.content}</div>#{post_vote}</div></li>")
        rebind_posts()
        $(document).scroll ->
          try_scroll_load_posts()


element_in_scroll = (elem)->
  totalHeight = 0
  currentScroll = 0
  visibleHeight = 0
  
  if (document.documentElement.scrollTop)
    currentScroll = document.documentElement.scrollTop
  else
    currentScroll = document.body.scrollTop
  
  totalHeight = document.body.offsetHeight
  visibleHeight = document.documentElement.clientHeight
  
  totalHeight <= currentScroll + visibleHeight and ($('.feed_end')[0])

reveal_switch = (switch_input)->
  if switch_input.data().revealed
    hide_post(switch_input)
  else
    reveal_post(switch_input)

reveal_post = (switch_input)->
  switch_input.unbind()
  id = switch_input.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/reveal/#{id}",
      type: 'PUT'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      error: ->
        $('.reveal-switch-input').on click: (e)->
          e.preventDefault()
          e.stopPropagation()
          reveal_switch($(this))
        alert('reveal fail')
      success: (data) ->
        if data.success
          $('#reveal-switch-span').text('Hidden')
          switch_input.data('revealed', true)
          $('.post_username').html("<a class=\"post_username_link\" href=\"/users/#{data.user_id}\">#{data.username}</a>")
          $('.post_avatar_div').html("<a class=\"post_avatar_link\" href=\"/users/#{data.user_id}\"><img src=#{data.avatar_thumb} class=\"post_avatar_image\"></a>")
          switch_input.on click: (e)->
            e.preventDefault()
            e.stopPropagation()
            hide_post($(this))
        else
          switch_input.on click: (e)->
            e.preventDefault()
            e.stopPropagation()
            reveal_post($(this))
          alert('reveal fail')

hide_post = (switch_input)->
  switch_input.unbind()
  id = switch_input.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/hide/#{id}",
      type: 'PUT'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      error: ->
        $('.reveal-switch-input').on click: (e)->
          e.preventDefault()
          e.stopPropagation()
          reveal_switch($(this))
        alert('hide fail')
      success: (data) ->
        if data.success
          $('#reveal-switch-span').text('Public')
          switch_input.data('revealed', false)
          $('.post_username').html('Anonymous (Me)')
          $('.post_avatar_div').html("<img src=#{data.avatar_thumb} class=\"post_avatar_image\">")
          switch_input.on click: (e)->
            e.preventDefault()
            e.stopPropagation()
            reveal_post($(this))
        else
          switch_input.on click: (e)->
            e.preventDefault()
            e.stopPropagation()
            hide_post($(this))
          alert('hide fail')

delete_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/#{id}",
      type: 'DELETE'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        link.parent().remove()
      error: ->
        link.on click: (e)->
          e.stopPropagation()
          delete_post($(this))
        alert('delete fail')
      success: (data) ->
        if data.success
          $('.post').fadeOut("slow", delete_redirect())
        else
          alert('delete fail')

delete_redirect = ->
  window.location = "/posts_location"

post_watch = (watch_btn)->
  watch_btn.unbind()
  watch_btn.next().unbind()
  id = watch_btn.parent().data().id
  uservote = watch_btn.parent().data().uservote
  isposter = watch_btn.parent().data().isposter
  if uservote!='watch' and !isposter
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    method_type = 'POST'
    url = "#{api_url}/votes"
    if uservote=='ignore'
      method_type = 'PUT'
      url = "#{api_url}/votes/update"
    $.ajax url,
        type: method_type
        contentType: 'application/json'
        dataType: "json"
        data: JSON.stringify({vote: {post_id: id, user_id: user_id, action: "watch"}})
        beforeSend: (request) ->
          request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        error: ->
          alert('vote failed')
        success: (data)->
          if data.success
            update_items_for_watch(id)
          else
            alert('vote failed')
        complete: ->
          watch_btn.on click: (e)->
            e.stopPropagation()
            post_watch($(this))
          watch_btn.next().on click: (e)->
            e.stopPropagation()
            post_ignore($(this))


post_ignore = (ignore_btn)->
  ignore_btn.unbind()
  ignore_btn.prev().unbind()
  id = ignore_btn.parent().data().id
  uservote = ignore_btn.parent().data().uservote
  isposter = ignore_btn.parent().data().isposter
  if uservote!='ignore' and !isposter
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    method_type = 'POST'
    url = "#{api_url}/votes"
    if uservote=='watch'
      method_type = 'PUT'
      url = "#{api_url}/votes/update"
    $.ajax url,
        type: method_type
        contentType: 'application/json'
        dataType: "json"
        data: JSON.stringify({vote: {post_id: id, user_id: user_id, action: "ignore"}})
        beforeSend: (request) ->
          request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        error: ->
          alert('vote failed')
        success:(data)->
          if data.success
            update_items_for_ignore(id)
          else
            alert('vote failed')
        complete: ->
          ignore_btn.prev().on click: (e)->
            e.stopPropagation()
            post_watch($(this))
          ignore_btn.on click: (e)->
            e.stopPropagation()
            post_ignore($(this))


update_items_for_watch = (post_id)->
  for post in $(".#{post_id}")
    watch_btn = $(post).find('.post_watch:first')
    ignore_dif = 0
    if watch_btn.next().hasClass('bold')
      ignore_dif = -1
    watch_stat = watch_btn.parent().data().watchstat
    ignore_stat = watch_btn.parent().data().ignorestat
    watch_btn.html("<i class=\"fi-eye\"></i> #{watch_stat+1}")
    watch_btn.next().html("<i class=\"fi-dislike\"></i> #{ignore_stat+ignore_dif}")
    watch_btn.attr('class', 'post_watch bold')
    watch_btn.next().removeClass('bold')
    watch_btn.parent().data('uservote', 'watch')
    watch_btn.parent().data('watchstat', watch_stat+1)
    watch_btn.parent().data('ignorestat', ignore_stat+ignore_dif)


update_items_for_ignore = (post_id)->
  for post in $(".#{post_id}")
    ignore_btn = $(post).find('.post_ignore:first')
    watch_dif = 0
    if ignore_btn.prev().hasClass('bold')
      watch_dif = -1
    watch_stat = ignore_btn.parent().data().watchstat
    ignore_stat = ignore_btn.parent().data().ignorestat
    ignore_btn.prev().html("<i class=\"fi-eye\"></i> #{watch_stat+watch_dif}")
    ignore_btn.html("<i class=\"fi-dislike\"></i> #{ignore_stat+1}")
    ignore_btn.prev().removeClass('bold')
    ignore_btn.attr('class', 'post_ignore bold')
    ignore_btn.parent().data('uservote', 'ignore')
    ignore_btn.parent().data('ignorestat', ignore_stat+1)
    ignore_btn.parent().data('watchstat', watch_stat+watch_dif)


setup_location = ->
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition(geo_success, geo_error)
  else
    alert("Browser does not support geolocation")

geo_success = (data)->
  location = data.coords
  if post_page == 'new'
    $('#latitude').val(location.latitude)
    $('#longitude').val(location.longitude)
  else if post_page == 'index_location'
    load_posts()

geo_error = (error)->
  code = error.code
  switch code
    when 0 then alert("Geolocation Error: Unknown error")
    when 1 then alert("Geolocation Error: Permission denied")
    when 2 then alert("Geolocation Error: Position unavailable")
    else alert("Geolocation Error: Timed out")
