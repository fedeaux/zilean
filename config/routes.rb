Rails.application.routes.draw do
  devise_for :users
  resources :users

  namespace :api, defaults: { format: 'json' } do
    resources :activities
    resources :log_entries do
      post 'crop' => 'log_entries#crop', on: :collection
    end
  end

  get 'templates/*name' => "dashboard#template"
  root 'dashboard#index'
end
