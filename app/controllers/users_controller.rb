class UsersController < ApplicationController
  def create
    if params[:password]!=params[:confirm_password]
      flash[:error] = "Passwords must match"
      redirect_to root_path
    else
      result = HTTParty.post("#{api_url}/users", 
      :body => { :user => {:username => params[:username], 
                  :password => params[:password]}
               }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
      if result['success']
        flash[:success] = "Welcome to Reveal!"
        set_current_user(result)
        redirect_to root_path
      else
        flash[:error] = "Invalid registration"
        redirect_to root_path
      end
    end
  end

  def login
    result = HTTParty.post("#{api_url}/users/login", 
    :body => { :user => {:username => params[:username], 
                :password => params[:password]}
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    if result['success']
      flash[:success] = "Welcome to Reveal!"
      set_current_user(result)
      redirect_to root_path
    else
      flash[:error] = "Invalid username/password"
      redirect_to root_path
    end
  end

  def show
    if authenticated?
      @user =  HTTParty.get("#{api_url}/users/#{params[:id]}",
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
      @user_posts = HTTParty.get("#{api_url}/posts/index_for_user/#{params[:id]}",
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
    else
      @user =  HTTParty.get("#{api_url}/users/#{params[:id]}")
      @user_posts = HTTParty.get("#{api_url}/posts/index_for_user/#{params[:id]}")
    end
  end

  def settings
    @user =  HTTParty.get("#{api_url}/users/#{params[:id]}")
    if authenticated?
      @user_posts = HTTParty.get("#{api_url}/posts/index_for_user/#{params[:id]}",
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
    else
      redirect_to root_path
    end
  end

  def logout
    session.clear
    redirect_to root_path
  end
end