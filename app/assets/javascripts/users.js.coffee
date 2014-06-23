api_url="http://reveal-api.herokuapp.com"
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
        $('#settings_user_avatar').attr('src', api_url+data.avatar_medium)
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
        $('#settings_user_avatar').attr('src', api_url+data.avatar_medium)
      else
        alert('There was an error uploading')

