Rails.application.routes.draw do

  # Log in/out
  get '/login' => "sessions#new", as: :login
  post '/login' => "sessions#create"
  get '/logout' => "sessions#destroy", as: :logout

  # Register
  get '/register' => "users#new", as: :register
  post '/register' => "users#create"

  # Profile
  get '/profile' => "users#show"
  resources :users, only: [:show,:edit,:update] do
    
  end

  # Leagues
  resources :leagues

  root 'home#index'
end
