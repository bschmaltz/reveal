class ApplicationController < ActionController::Base
  helper :application
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def home
    if authenticated?
      redirect_to '/posts'
    end
  end

  protected

  def authenticated?
    !session[:user].nil?
  end

  def set_current_user(result)
    session[:user] = {id: result['id'], username: result['username'], auth_token: result['auth_token']}
  end

  def current_user
    session[:user]
  end

  def api_url
    "http://reveal-api.herokuapp.com"
    #"http://localhost:3001"
  end

  def authorize
    if !authenticated?
      flash[:error] = "You need to log in to do that."
      redirect_to root_path
    end
  end
end
