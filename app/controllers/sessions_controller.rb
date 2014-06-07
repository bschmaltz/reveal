class SessionsController < ApplicationController
  def create
    @result = HTTParty.post("http://localhost:3000/sessions", 
    :body => { :session => {:username => params[:username], 
                :password => params[:password]}
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )
    puts "@@@@@@@@@@@@@@2#{@result.inspect}"
    if @result['id']!=nil
      session[:id] = @result['session_id']
      redirect_to root_path
    else
      flash.now[:error] = 'Invalid email/password combination'
      redirect_to root_path
    end
  end

  def destroy
    @result = HTTParty.delete("http://localhost:3000/users/#{session[:user_id]}")
    if @result['success']
      session.clear
      flash[:success] = "You've successfully logged out!"
      redirect_to root_path
    else
      flash[:error] = "You failed to log out."
      redirect_to root_path
    end
  end
end