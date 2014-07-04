class PostsController < ApplicationController
  before_filter :authorize, :only => [:new, :create]
  def new
  end

  def create
    result = HTTParty.post("#{api_url}/posts", 
      :body => { :post => {:user_id => current_user['id'], 
                  :content => params[:content],
                  :latitude => params[:latitude],
                  :longitude => params[:longitude],
                  :revealed => false}
               }.to_json,
      :headers => { 'Content-Type' => 'application/json',
        'Authorization' => "Token token=#{current_user['auth_token']}" } )
    if result['success']
      flash[:success] = "Post created!"
      redirect_to action: 'index'
    else
      flash[:error] = "Error creating post. Try again."
      redirect_to action: 'new'
    end
  end

  def index
    if authenticated?
      @posts = HTTParty.get("#{api_url}/posts/index", 
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
    else
      @posts = HTTParty.get("#{api_url}/posts/index")
    end
  end

  def index_popular
    if authenticated?
      @posts = HTTParty.get("#{api_url}/posts/index_popular", 
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
    else
      @posts = HTTParty.get("#{api_url}/posts/index_popular")
    end
    puts "@@@@@@@@@@@@@@@@@@@@@posts=#{@posts.inspect}"
    render 'index'
  end

  def index_followed
    if authenticated?
      @posts = HTTParty.get("#{api_url}/posts/index_followed_posts", 
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
      render 'index'
    else
      redirect_to root_path
    end
  end

  def index_location
    @posts = []
    render 'index'
  end

  def show
    if authenticated?
      @post = HTTParty.get("#{api_url}/posts/show/#{params[:id]}", 
        :headers => { 'Authorization' => "Token token=#{current_user['auth_token']}" })
    else
      @post = HTTParty.get("#{api_url}/posts/show/#{params[:id]}")
    end
  end
end