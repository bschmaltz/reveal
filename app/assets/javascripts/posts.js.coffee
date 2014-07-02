#api_url="https://reveal-api.herokuapp.com"
api_url="http://localhost:3001"
feed = 'index'
$ ->
  if $('.posts')[0]
    feed = $('.posts').data().feed
  $(document).scroll ->
    load_posts()
  rebind_posts()


rebind_posts = ->
  $('.reveal_post').on click: (e)->
    e.stopPropagation()
    reveal_post($(this))
    
  $('.hide_post').on click: (e)->
    e.stopPropagation()
    hide_post($(this))
    
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


load_posts = ->
  last_post = $('.post').last()
  if element_in_scroll($('#feed_end'))
    $(document).unbind('scroll')
    url=''
    if feed=='index'
      url = "#{api_url}/posts/index/#{last_post.data().id}"
    else
      if last_post.data().itemtype=='watch'
        url="#{api_url}/posts/index_followed_posts?last_vote_id=#{last_post.data().voteid}"
      else
        url="#{api_url}/posts/index_followed_posts?last_post_id=#{last_post.data().id}"
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
          last_post.parent().after('<div id="end_of_posts">You\'ve reached the end of the feed</div>')
        else
          for post in data
            username = ""
            post_vote = ""
            post_data = "data-id=#{post.id}  data-itemtype=\"#{post.item_type}\" data-voteid=\"#{post.vote_id}\""
            vote_data="data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-watchstat=\"#{post.watch_stat}\" data-ignorestat=\"#{post.ignore_stat}\""
            post_avatar = "<div class=\"post_avatar_div\"><img src=\""+post.avatar_thumb+"\" class=\"post_avatar_image\"></div>"
            watch_info = ""
            if !post.revealed and post.current_user_is_poster
              username = "<div class=\"post_username\">user: Anonymous (Me)</div>"
            else if !post.revealed
              username = "<div class=\"post_username\">user: Anonymous</div>"
            else
              username ="<div class=\"post_username\">user: <a class=\"post_username_link\" href=\"/users/#{post.user_id}\">#{post.username}</a></div>"
              post_avatar = "<div class=\"post_avatar_div\"><a class=\"post_avatar_link\" href=\"/users/#{post.user_id}\"><img src=\""+post.avatar_thumb+"\" class=\"post_avatar_image\"></a></div>"

            if post.current_user_is_poster
              post_vote = "<div class=\"post_vote\" #{vote_data}><div class=\"post_watch\">WATCH</div><div class=\"post_ignore\">IGNORE</div></div>"
            else
              if post.current_user_vote == 'watch'
                post_vote = "<div class=\"post_vote\" #{vote_data}><div class=\"post_watch bold\">WATCH</div><div class=\"post_ignore\">IGNORE</div></div>"
              else if post.current_user_vote == 'ignore'
                post_vote = "<div class=\"post_vote\" #{vote_data}><div class=\"post_watch\">WATCH</div><div class=\"post_ignore bold\">IGNORE</div></div>"
              else
                post_vote = "<div class=\"post_vote\" #{vote_data}><div class=\"post_watch\">WATCH</div><div class=\"post_ignore\">IGNORE</div></div>"

            if post.item_type == 'watch'
              watch_info = "<div class=\"watch_info\">Watched by <a class=\"watch_user_link\" href=\"users/#{post.followed_user_id}\">#{post.followed_username}</a></div>"

            $('.post').last().after("<li #{post_data} class=\"post post_listing #{post.id}\">#{post_vote}#{username}#{post_avatar}<div class=\"post_content\">says: #{post.content}</div><div class=\"post_watch_stat\">watches: #{post.watch_stat}</div><div class=\"post_ignore_stat\">ignores: #{post.ignore_stat}</div>#{watch_info}</li>")
          rebind_posts()
          $(document).scroll ->
            load_posts()


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


reveal_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/reveal/#{id}",
      type: 'PUT'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      error: ->
        link.on click: (e)->
          e.stopPropagation()
          reveal_post($(this))
        alert('reveal fail')
      success: (data) ->
        link.text('hide')
        link.attr('class', 'post_control hide_post')
        link.on click: (e)->
          e.stopPropagation()
          hide_post($(this))
        link.parent().find('.post_username').text("user: "+data.username)
        link.parent().find('.post_avatar_image').attr('src', data.avatar_thumb)


hide_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/hide/#{id}",
      type: 'PUT'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      error: ->
        link.on click: (e)->
          e.stopPropagation()
          hide_post($(this))
        alert('hide fail')
      success: (data) ->
        link.text('reveal')
        link.attr('class', 'post_control reveal_post')
        link.on click: (e)->
          e.stopPropagation()
          reveal_post($(this))
        link.parent().find('.post_username').text('user: Anonymous (Me)')
        link.parent().find('.post_avatar_image').attr('src', data.avatar_thumb)


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
    watch_btn.attr('class', 'post_watch bold')
    watch_btn.next().removeClass('bold')
    watch_btn.parent().parent().find('.post_watch_stat').text("watches: #{watch_stat+1}")
    watch_btn.parent().data('uservote', 'watch')
    watch_btn.parent().data('watchstat', watch_stat+1)
    watch_btn.parent().parent().find('.post_ignore_stat').text("ignores: #{ignore_stat+ignore_dif}")
    watch_btn.parent().data('ignorestat', ignore_stat+ignore_dif)


update_items_for_ignore = (post_id)->
  for post in $(".#{post_id}")
    ignore_btn = $(post).find('.post_ignore:first')
    watch_dif = 0
    if ignore_btn.prev().hasClass('bold')
      watch_dif = -1
    watch_stat = ignore_btn.parent().data().watchstat
    ignore_stat = ignore_btn.parent().data().ignorestat
    ignore_btn.attr('class', 'post_ignore bold')
    ignore_btn.prev().removeClass('bold')
    ignore_btn.parent().parent().find('.post_ignore_stat').text("ignores: #{ignore_stat+1}")
    ignore_btn.parent().data('uservote', 'ignore')
    ignore_btn.parent().data('ignorestat', ignore_stat+1)
    ignore_btn.parent().parent().find('.post_watch_stat').text("watches: #{watch_stat+watch_dif}")
    ignore_btn.parent().data('watchstat', watch_stat+watch_dif)

