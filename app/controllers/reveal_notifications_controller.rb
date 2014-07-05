class RevealNotificationsController < ApplicationController
  before_filter :authorize, :only => [:index]

  def index
    if authenticated?
      @notifications = HTTParty.get("#{api_url}/reveal_notifications", 
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
      @view_result = HTTParty.put("#{api_url}/reveal_notifications/viewed_new_notifications", 
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
    else
      redirect_to root_path
    end
  end
end