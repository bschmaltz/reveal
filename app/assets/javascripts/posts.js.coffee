api_url="http://reveal-api.herokuapp.com"

$ ->
  $(document).scroll ->
    load_posts()
  rebind_posts()

rebind_posts = ->
  $('.reveal_post').on click: ->
    reveal_post($(this))
    
  $('.hide_post').on click: ->
    hide_post($(this))
    
  $('.delete_post').on click: ->
    delete_post($(this))

  $('.post_vote_up').on click: ->
    post_vote_up($(this))

  $('.post_vote_down').on click: ->
    post_vote_down($(this))

load_posts = ->
  last_post = $('.post').last()
  if element_in_scroll($('#feed_end'))
    $(document).unbind('scroll')
    id = last_post.attr('id')
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    $.ajax "#{api_url}/posts/index/#{id}",
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
            username = if (!post.revealed and post.current_user_is_poster) then "Anonymous (Me)" else post.username
            post_vote = ""
            reveal_link = ""
            delete_link = ""
            post_data="data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-vote=\"#{post.vote_stat}\""
            if post.current_user_is_poster
              if !post.revealed
                reveal_link = "<a href=\"\" data-id=\"#{post.id}\" class=\"reveal_post\">reveal</a>"
              else
                reveal_link = "<a href=\"\" data-id=\"#{post.id}\" class=\"hide_post\">hide</a>"
              delete_link = "<a href=\"\" data-id=\"#{post.id}\" class=\"delete_post\">delete</a>"
              post_vote = "<div class=\"post_vote\" data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-vote=\"#{post.vote_stat}\"><div class=\"post_vote_up bold\">+</div><div class=\"post_vote_down\">-</div></div>"
            else
              if post.current_user_vote == 'up'
                post_vote = "<div class=\"post_vote\" data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-vote=\"#{post.vote_stat}\"><div class=\"post_vote_up bold\">+</div><div class=\"post_vote_down\">-</div></div>"
              else if post.current_user_vote == 'down'
                post_vote = "<div class=\"post_vote\" data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-vote=\"#{post.vote_stat}\"><div class=\"post_vote_up\">+</div><div class=\"post_vote_down bold\">-</div></div>"
              else
                post_vote = "<div class=\"post_vote\" data-uservote=\"#{post.current_user_vote}\" data-id=\"#{post.id}\" data-isposter=\"#{post.current_user_is_poster}\" data-vote=\"#{post.vote_stat}\"><div class=\"post_vote_up\">+</div><div class=\"post_vote_down\">-</div></div>"

            $('.post').last().after("<li id=\"#{post.id}\" #{post_data} class=\"post\">#{post_vote}<div class=\"post_username\">user: #{username}</div><div class=\"post_content\">says: #{post.content}</div><div class=\"post_vote_stat\">votes: #{post.vote_stat}</div><div class=\"post_share_stat\">shares: #{post.share_stat}</div>#{reveal_link} #{delete_link}</li>")
          rebind_posts()
          $(document).scroll ->
            load_posts()


element_in_scroll = (elem)->
  docViewTop = $(window).scrollTop();
  docViewBottom = docViewTop + $(window).height()

  elemTop = elem.offset().top
  elemBottom = elemTop + elem.height()

  ((elemBottom <= docViewBottom) and (elemTop >= docViewTop))



reveal_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/reveal/#{id}",
      type: 'PUT'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        link.parent().fadeOut('fast')
      error: ->
        alert('reveal fail')
        link.parent().fadeIn('fast')
      success: (data) ->
        link.text('hide')
        link.attr('class', 'post_control hide_post')
        link.on click: ->
          hide_post($(this))
        link.parent().find('.post_username').text("user: "+data.username)
        link.parent().find('.post_avatar_image').attr('src', api_url+data.avatar_thumb)
        link.parent().fadeIn('fast')

hide_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/hide/#{id}",
      type: 'PUT'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        link.parent().fadeOut('fast')
      error: ->
        alert('hide fail')
        link.parent().fadeIn('fast')
      success: (data) ->
        link.text('reveal')
        link.attr('class', 'post_control reveal_post')
        link.on click: ->
          reveal_post($(this))
        link.parent().find('.post_username').text('user: Anonymous (Me)')
        link.parent().find('.post_avatar_image').attr('src', api_url+"/assets/default_avatars/thumb/anonymous.jpg")
        link.parent().fadeIn('fast')

delete_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/posts/#{id}",
      type: 'DELETE'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        link.parent().fadeOut('fast')
      error: ->
        link.on click: ->
          delete_post($(this))
        alert('delete fail')
        link.parent().fadeIn('fast')

post_vote_up = (up_arrow)->
  up_arrow.unbind()
  up_arrow.next().unbind()
  id = up_arrow.parent().data().id
  uservote = up_arrow.parent().data().uservote
  isposter = up_arrow.parent().data().isposter
  vote_stat = up_arrow.parent().data().vote
  if uservote!='up' and !isposter
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    method_type = 'POST'
    url = "#{api_url}/votes"
    if uservote=='down'
      method_type = 'PUT'
      url = "#{api_url}/votes/update"
    $.ajax url,
        type: method_type
        contentType: 'application/json'
        dataType: "json"
        data: JSON.stringify({vote: {post_id: id, user_id: user_id, up: true}})
        beforeSend: (request) ->
          request.setRequestHeader("Authorization", "Token token=#{auth_token}")
          up_arrow.parent().fadeOut('fast')
        error: ->
          alert('vote failed')
          up_arrow.on click: (e)->
            e.preventDefault()
            post_vote_up($(this))
          up_arrow.parent().fadeIn('fast')
        success: (data)->
          if data.success
            up_arrow.attr('class', 'post_vote_down bold')
            up_arrow.next().removeClass('bold')
            up_arrow.parent().parent().find('.post_vote_stat').text("votes: #{vote_stat+1}")
            up_arrow.parent().data('uservote', 'up')
            up_arrow.parent().data('vote', vote_stat+1)
            up_arrow.on click: (e)->
              e.preventDefault()
              post_vote_up($(this))
            up_arrow.parent().fadeIn('fast')
          else
            alert('vote failed')
            up_arrow.on click: (e)->
              e.preventDefault()
              post_vote_down($(this))
            up_arrow.parent().fadeIn('fast')
          up_arrow.parent().fadeIn('fast')
        complete: ->
          up_arrow.on click: ->
            post_vote_up($(this))
          up_arrow.next().on click: ->
            post_vote_down($(this))

post_vote_down = (down_arrow)->
  down_arrow.unbind()
  down_arrow.prev().unbind()
  id = down_arrow.parent().data().id
  uservote = down_arrow.parent().data().uservote
  isposter = down_arrow.parent().data().isposter
  vote_stat = down_arrow.parent().data().vote
  if uservote!='down' and !isposter
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    method_type = 'POST'
    url = "#{api_url}/votes"
    if uservote=='up'
      method_type = 'PUT'
      url = "#{api_url}/votes/update"
    $.ajax url,
        type: method_type
        contentType: 'application/json'
        dataType: "json"
        data: JSON.stringify({vote: {post_id: id, user_id: user_id, up: false}})
        beforeSend: (request) ->
          request.setRequestHeader("Authorization", "Token token=#{auth_token}")
          down_arrow.parent().fadeOut('fast')
        error: ->
          alert('vote failed')
          down_arrow.on click: (e)->
            e.preventDefault()
            post_vote_down($(this))
          down_arrow.parent().fadeIn('fast')
        success:(data)->
          if data.success
            down_arrow.attr('class', 'post_vote_down bold')
            down_arrow.prev().removeClass('bold')
            down_arrow.parent().parent().find('.post_vote_stat').text("votes: #{vote_stat-1}")
            down_arrow.parent().data('uservote', 'down')
            down_arrow.parent().data('vote', vote_stat-1)
            down_arrow.on click: (e)->
              e.preventDefault()
              post_vote_down($(this))
            down_arrow.parent().fadeIn('fast')
          else
            alert('vote failed')
            down_arrow.on click: (e)->
              e.preventDefault()
              post_vote_down($(this))
            down_arrow.parent().fadeIn('fast')
        complete: ->
          down_arrow.prev().on click: ->
            post_vote_up($(this))
          down_arrow.on click: ->
            post_vote_down($(this))