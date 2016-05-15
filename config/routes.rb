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
  get '/profile', to: "profile#show", as: :my_profile
  resource :profile, except: [:new,:create], controller: :profile do
    post '/password', to: "profile#update_password", as: :update_password
    match '/notifications', to: "profile#update_notifications", as: :update_notifications, via:[:post,:patch,:put]
  end
  get '/profile/:id/:username', to: "profile#show", as: :show_profile

  # Leagues
  resources :leagues do
    collection do
      get 'search', to: 'leagues#search', as: :search
      get 'nearby', to: 'leagues#nearby', as: :nearby
      match 'search_api', to: 'leagues#search_api', as: :search_api, via: [:get,:post]
    end
    member do
      scope :broadcast do
        get '/', to: 'leagues#new_broadcast', as: :broadcast
        post '/', to: 'leagues#create_broadcast', as: :send_broadcast
        match "preview", to: "leagues#preview_broadcast", as: :preview_broadcast, via: [:get,:post]
      end
    end
    resources :join, controller: "liga_users", only: [:create,:destroy] do
      member do
        # user requests
        get 'approve'
      end
    end
    post 'invite', to: 'liga_users#invite'
    get 'invite/:token', to: 'liga_users#view_invite', as: "view_invite"
    post 'invite/:token/accept', to: 'liga_users#accept_invite', as: 'accept_invite'
    post 'invite/:token/dismiss', to: 'liga_users#dismiss_invite', as: 'dismiss_invite'

    get 'member/:id/promote', to: 'liga_users#promote', as: :promote_member
    get 'member/:id/demote', to: 'liga_users#demote', as: :demote_member
    get 'member/:id/ban', to: 'liga_users#ban', as: :ban_member

    resources :seasons do
      member do
        get '/activate', to: 'seasons#activate'
      end
      resources :games do
      end
    end
  end
  get '/leagues/:id/:slug', to: "leagues#show", as: :show_league

  # Admin tools
  get '/admin' => 'admin#index'
  namespace :admin do
    resources :results, except: [:new,:show]
    resources :factions, except:[:new,:show]
    resources :identities, except:[:new,:show]
    resources :users do
      collection do
        get 'search'
      end
    end
  end

  get '/about', to: 'home#about'
  get '/blank', to: 'home#blank'

  root 'home#index'
end
