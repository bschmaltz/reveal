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


reveal_post = (link)->
  link.unbind()
  id = link.data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "http://localhost:3001/posts/reveal/#{id}",
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
  $.ajax "http://reveal-api.heroku.com/posts/hide/#{id}",
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
  $.ajax "http://reveal-api.heroku.com/posts/#{id}",
      type: 'DELETE'
      contentType: 'application/json'
      beforeSend: (request) ->
        request.setRequestHeader("Authorization", "Token token=#{auth_token}")
        link.parent().fadeOut('fast')
      error: ->
        alert('delete fail')
        link.parent().fadeIn('fast')
