Rails.application.routes.draw do
  root to: 'application#home'

  post '/users', to: 'users#create'
  post '/users/login', to: 'users#login'
  get '/users/logout', to: 'users#logout', as: :logout
end
