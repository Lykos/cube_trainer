Rails.application.routes.draw do
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#logout'
  get 'welcome', to: 'sessions#welcome'
  resources :users
  get 'timer/index'
  post 'timer/next_input'
  post 'timer/stop'
  post 'timer/delete'
  post 'timer/drop_input'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
