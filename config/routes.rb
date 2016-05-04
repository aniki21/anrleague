Rails.application.routes.draw do

  # Log in/out
  get '/login', to: "sessions#new", as: :login
  post '/login', to: "sessions#create"
  get '/logout', to: "sessions#destroy", as: :logout

  # Register
  get '/register', to: "profile#new", as: :register
  post '/register', to: "profile#create"

  # Password reset
  resources :password_reset, except: [:index,:destroy]

  # Profile
  get '/profile', to: "profile#show", as: :profile
  get '/profile/:id/:username', to: "profile#show"
  resource :profile, except: [:new,:create,:show], controller: :profile do
    post '/password', to: "profile#update_password", as: :update_password
  end

  # Leagues
  resources :leagues do
    collection do
      get 'search', to: 'leagues#search', as: :search
    end
    member do
      get 'signup', to: 'leagues#signup', as: :signup
    end
    resources :seasons do
    resources :games do
    end
    end
  end
  get '/leagues/:id/:slug', to: "leagues#show", as: :show_league

  # Admin tools
  get '/admin' => 'admin#index'
  namespace :admin do
    resources :results, except: [:new,:show]
  end

  root 'home#index'
end
