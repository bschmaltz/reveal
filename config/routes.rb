Rails.application.routes.draw do
  root to: 'application#home'

  post '/users', to: 'users#create'
  post '/users/login', to: 'users#login'
  get '/users/logout', to: 'users#logout', as: :logout

  get '/posts/new', to: 'posts#new', as: :new_post
  get '/posts', to: 'posts#index'
  get '/posts/:id', to: 'posts#show'
  post '/posts', to: 'posts#create'
  get '/posts/reveal/:id', to: 'posts#reveal'
  get '/posts/delete/:id', to: 'posts#destroy'
end
