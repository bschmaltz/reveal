Rails.application.routes.draw do
  root to: 'application#home'
  resources :users
  resources :sessions

  get '/logout', to: 'sessions#destroy', as: :logout
end
