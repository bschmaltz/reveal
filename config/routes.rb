Rails.application.routes.draw do
  root to: 'application#home'

  post '/users', to: 'users#create'
  get '/users/:id', to: 'users#show'
  get '/users/settings/:id', to: 'users#settings'
  post '/users/login', to: 'users#login'
  get '/users_logout', to: 'users#logout', as: :logout

  get '/posts/new', to: 'posts#new', as: :new_post
  get '/posts', to: 'posts#index'
  get '/posts_followed', to: 'posts#index_followed'
  get '/posts_location', to: 'posts#index_location'
  get '/posts/:id', to: 'posts#show'
  post '/posts', to: 'posts#create'
end
