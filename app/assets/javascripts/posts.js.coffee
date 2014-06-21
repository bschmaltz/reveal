$ ->
  $('.reveal_post').on click: (e)->
    e.preventDefault()
    reveal_post($(this))
    
  $('.hide_post').on click: (e)->
    e.preventDefault()
    hide_post($(this))
    
  $('.delete_post').on click: (e)->
    e.preventDefault()
    delete_post($(this))

  $('.post_vote_up').on click: (e)->
    e.preventDefault()
    post_vote_up($(this))

  $('.post_vote_down').on click: (e)->
    e.preventDefault()
    post_vote_down($(this))


reveal_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "http://reveal-api.herokuapp.com/posts/reveal/#{id}",
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
        link.attr('class', 'hide_post')
        link.on click: (e)->
          e.preventDefault()
          hide_post($(this))
        link.parent().find('.post_username').text("user: "+data.username)
        link.parent().fadeIn('fast')

hide_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "http://reveal-api.herokuapp.com/posts/hide/#{id}",
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
        link.attr('class', 'reveal_post')
        link.on click: (e)->
          e.preventDefault()
          reveal_post($(this))
        link.parent().find('.post_username').text('user: Anonymous (Me)')
        link.parent().fadeIn('fast')

delete_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "http://reveal-api.herokuapp.com/posts/#{id}",
      type: 'DELETE'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        link.parent().fadeOut('fast')
      error: ->
        alert('delete fail')
        link.parent().fadeIn('fast')

post_vote_up = (up_arrow)->
  up_arrow.unbind()
  id = up_arrow.parent().data().id
  uservote = up_arrow.parent().data().uservote
  isposter = up_arrow.parent().data().isposter
  vote_stat = up_arrow.parent().data().vote
  if uservote!='up' and !isposter
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    method_type = 'POST'
    url = 'http://reveal-api.herokuapp.com/votes'
    if uservote=='down'
      method_type = 'PUT'
      url = 'http://reveal-api.herokuapp.com/votes/update'
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

post_vote_down = (down_arrow)->
  down_arrow.unbind()
  id = down_arrow.parent().data().id
  uservote = down_arrow.parent().data().uservote
  isposter = down_arrow.parent().data().isposter
  vote_stat = down_arrow.parent().data().vote
  if uservote!='down' and !isposter
    auth_token = $("#auth_user_info").data().token
    user_id = $("#auth_user_info").data().id
    method_type = 'POST'
    url = 'http://reveal-api.herokuapp.com/votes'
    if uservote=='up'
      method_type = 'PUT'
      url = 'http://reveal-api.herokuapp.com/votes/update'
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
