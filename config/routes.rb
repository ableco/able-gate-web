Rails.application.routes.draw do
  namespace :admin do
    resources :settings
    resources :services
    resources :departments
    resources :projects
    resources :locations
    resources :users
    resources :action_logs, only: %i[index show delete destroy]

    root to: 'settings#index'
  end

  resources :onboardings, only: %i[create]
  resources :offboardings, only: %i[create update]

  root 'home#index'
  delete 'logout', to: 'sessions#destroy'
  get 'auth/google_oauth2/callback', to: 'sessions#create'
end
