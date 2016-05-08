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
    resources :join, controller: "liga_users", only: [:create] do
      member do
        # user requests
        post 'approve'
        post 'reject'
      end
    end
    post 'invite', to: 'liga_users#invite'
    get 'invite/:token', to: 'liga_users#view_invite', as: "view_invite"
    post 'invite/:token/accept', to: 'liga_users#accept_invite', as: 'accept_invite'
    post 'invite/:token/dismiss', to: 'liga_users#dismiss_invite', as: 'dismiss_invite'

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
