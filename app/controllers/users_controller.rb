class UsersController < ApplicationController
  def create
    if params[:password]!=params[:confirm_password]
      flash[:error] = "Passwords must match"
      redirect_to root_path
    else
      @result = HTTParty.post("http://localhost:3000/users", 
      :body => { :user => {:username => params[:username], 
                  :password => params[:password]}
               }.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
      if @result['success']
        flash[:success] = "Welcome to Reveal!"
        session[:auth_token]=@result['auth_token']
        session[:user_id]=@result['id']
        session[:username]=@result['username']
        redirect_to root_path
      else
        flash[:error] = "Invalid registration"
        redirect_to root_path
      end
    end
  end

  def login
    @result = HTTParty.post("http://localhost:3000/users/login", 
    :body => { :user => {:username => params[:username], 
                :password => params[:password]}
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    if @result['success']
      flash[:success] = "Welcome to Reveal!"
      session[:auth_token]=@result['auth_token']
      session[:user_id]=@result['id']
      session[:username]=@result['username']
      redirect_to root_path
    else
      flash[:error] = "Invalid username/password"
      redirect_to root_path
    end
  end

  def logout
    session.clear
    redirect_to root_path
  end
end