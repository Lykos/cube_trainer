Rails.application.routes.draw do
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#logout'
  get 'welcome', to: 'sessions#welcome'
  root 'sessions#welcome'
  resources :users
  resources :modes
  get 'training/:mode_id', to: 'timer#index', as: :timer
  post 'training/:mode_id/next_input', to: 'timer#next_input'
  post 'training/:mode_id/stop', to: 'timer#stop'
  post 'training/:mode_id/delete', to: 'timer#delete'
  post 'training/:mode_id/drop_input', to: 'timer#drop_input'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
