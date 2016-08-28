Rails.application.routes.draw do
  devise_for :users
  resources :users

  namespace :api, defaults: { format: 'json' } do
    resources :activities
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
