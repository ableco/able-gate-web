Rails.application.routes.draw do
  namespace :admin do
      resources :settings
      resources :services
      resources :departments
      resources :projects
      resources :locations
      resources :users

      root to: "settings#index"
    end
  root 'home#index'
  delete 'logout', to: 'sessions#destroy'

  resources :users

  put '/users/:user_id/accesses', to: 'accesses#update', as: 'update_accesses'
  get 'auth/google_oauth2/callback', to: 'sessions#create'
end
