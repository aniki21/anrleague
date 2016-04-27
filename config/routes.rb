Rails.application.routes.draw do

  # Log in/out
  get '/login', to: "sessions#new", as: :login
  post '/login', to: "sessions#create"
  get '/logout', to: "sessions#destroy", as: :logout

  # Register
  get '/register', to: "profile#new", as: :register
  post '/register', to: "profile#create"

  # Profile
  get '/profile', to: "profile#show", as: :profile
  get '/profile/:id/:username', to: "profile#show"
  resource :profile, except: [:new,:create,:show], controller: :profile do
    post '/password', to: "profile#update_password", as: :update_password
  end

  # Leagues
  resources :leagues do
    member do
      get 'signup', to: 'leagues#signup', as: :signup
    end
    resources :games do
    end
  end
  get '/leagues/:id/:slug', to: "leagues#show", as: :show_league

  root 'home#index'
end
