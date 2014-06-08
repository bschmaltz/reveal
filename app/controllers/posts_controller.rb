class PostsController < ApplicationController
  def new
  end

  def create
    @result = HTTParty.post("http://localhost:3000/posts", 
      :body => { :post => {:username => session[:username], 
                  :content => params[:content],
                  :revealed => false}
               }.to_json,
      :headers => { 'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{session[:auth_token]}" } )
    redirect_to action: 'index'
  end

  def index
    @posts = HTTParty.get("http://localhost:3000/posts")
  end

  def show
    @post = HTTParty.get("http://localhost:3000/posts/#{params[:id]}")
  end

  def reveal
    @result = HTTParty.put("http://localhost:3000/posts/reveal/#{params[:id]}", 
      :headers => { 'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{session[:auth_token]}" })
    redirect_to action: 'index'
  end

  def destroy
    @result = HTTParty.delete("http://localhost:3000/posts/#{params[:id]}", 
      :headers => { 'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{session[:auth_token]}" })
    redirect_to action: 'index'
  end
end