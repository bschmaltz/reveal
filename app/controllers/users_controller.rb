class UsersController < ApplicationController
  def create
    @result = HTTParty.post("http://localhost:3000/users", 
    :body => { :user => {:username => params[:username], 
                :password => params[:password]}
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    if @result['success']
      flash[:success] = "Welcome to Reveal!"
      session[:id]=@result['session_id']
      session[:user_id]=@result['id']
      session[:username]=@result['username']
      redirect_to root_path
    else
      redirect_to root_path
    end
  end
end