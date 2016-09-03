Rails.application.routes.draw do
  devise_for :users
  resources :users

  namespace :api, defaults: { format: 'json' } do
    resources :activities
    resources :log_entries
  end

  get 'templates/*name' => "dashboard#template"
  root 'dashboard#index'
end
