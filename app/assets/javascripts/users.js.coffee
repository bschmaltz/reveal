api_url="https://reveal-api.herokuapp.com"
#api_url="http://localhost:3001"
file = null
$ ->
  jQuery("#avatar_browser").on change: ->
    file = this.files[0]
    $('#avatar_remote_url').val('')

  $("#avatar_remote_url").on change: ->
    file=null
    $("#avatar_browser").val('')

  $('#avatar_uploader').submit (e)->
    e.preventDefault()
    e.stopPropagation()
    if $('#avatar_remote_url').val() == ''
      upload_avatar_from_browser()
    else
      upload_avatar_from_url()

  $('#follow_user').on click: (e)->
    e.stopPropagation()
    follow_user($(this))

  $('#unfollow_user').on click: (e)->
    e.stopPropagation()
    unfollow_user($(this))


follow_user = (follow_btn)->
  follow_btn.unbind()
  followed_user_id = follow_btn.data().id
  auth_token = $("#auth_user_info").data().token
  user_id = $("#auth_user_info").data().id
  $.ajax "#{api_url}/followers",
    type: 'POST'
    contentType: 'application/json'
    dataType: "json"
    data: JSON.stringify({follower: {user_id: user_id, followed_user_id: followed_user_id}})
    beforeSend: (request) ->
      request.setRequestHeader("Authorization", "Token token=#{auth_token}")
    error: ->
      follow_btn.on click: (e)->
        e.stopPropagation()
        follow_user($(this))
      follow_btn.blur()
      alert('follow fail')
    success: (data) ->
      if data.success
        follow_btn.attr('id', 'unfollow_user')
        follow_btn.text('following')
        follower_stat = $('#follower_stat').data().follower+1
        $('#follower_stat').data('follower', follower_stat)
        $('#follower_stat').text("#{follower_stat} followers")
        follow_btn.blur()
        follow_btn.on click: (e)->
          e.stopPropagation()
          unfollow_user($(this))
      else
        follow_btn.blur()
        follow_btn.on click: (e)->
          e.stopPropagation()
          follow_user($(this))
        alert('follow fail')


unfollow_user = (unfollow_btn)->
  unfollow_btn.unbind()
  unfollowed_user_id = unfollow_btn.data().id
  user_id = $("#auth_user_info").data().id
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/followers",
    type: 'DELETE'
    contentType: 'application/json'
    dataType: "json"
    data: JSON.stringify({follower: {user_id: user_id, followed_user_id: unfollowed_user_id}})
    beforeSend: (request) ->
      request.setRequestHeader("Authorization", "Token token=#{auth_token}")
    error: ->
      unfollow_btn.on click: (e)->
        e.stopPropagation()
        unfollow_user($(this))
      unfollow_btn.blur()
      alert('unfollow fail')
    success: (data) ->
      if data.success
        unfollow_btn.attr('id', 'follow_user')
        unfollow_btn.text('follow')
        follower_stat = $('#follower_stat').data().follower-1
        $('#follower_stat').data('follower', follower_stat)
        $('#follower_stat').text("#{follower_stat} followers")
        unfollow_btn.blur()
        unfollow_btn.on click: (e)->
          e.stopPropagation()
          follow_user($(this))
      else
        unfollow_btn.blur()
        unfollow_btn.on click: (e)->
          e.stopPropagation()
          unfollow_user($(this))
        alert('unfollow fail')


upload_avatar_from_browser = ->
  formdata = new FormData()
  formdata.append("avatar", file)
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/users/setting/update_avatar",
    type: 'POST'
    processData: false
    contentType: false
    data: formdata
    beforeSend: (request) ->
      request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      $('.ajax_loader').show()
    error: ->
      $('.ajax_loader').hide()
      alert('Upload failed.')
    success: (data) ->
      $('.ajax_loader').hide()
      if data.success
        $('#settings_user_avatar').attr('src', data.avatar_medium)
      else
        alert('There was an error uploading')


upload_avatar_from_url = ->
  auth_token = $("#auth_user_info").data().token
  $.ajax "#{api_url}/users/setting/update_avatar?remote_url=#{$('#avatar_remote_url').val()}",
    type: 'POST'
    beforeSend: (request) ->
      request.setRequestHeader("Authorization", "Token token=#{auth_token}")
      $('.ajax_loader').show()
    error: ->
      $('.ajax_loader').hide()
      alert('Upload failed.')
    success: (data) ->
      $('.ajax_loader').hide()
      if data.success
        $('#settings_user_avatar').attr('src', data.avatar_medium)
      else
        alert('There was an error uploading')

