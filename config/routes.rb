Rails.application.routes.draw do
  get 'signup', to: 'users#new'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#logout'
  get 'welcome', to: 'sessions#welcome'
  root 'sessions#welcome'
  resources :users
  resources :modes do
    resources :results, only: [:index, :show, :destroy]
  end
  get 'trainer/:mode_id', to: 'trainer#index'
  post 'trainer/:mode_id/inputs', to: 'trainer#create'
  delete 'trainer/:mode_id/inputs/:id', to: 'trainer#destroy'
  post 'trainer/:mode_id/inputs/:id', to: 'trainer#stop'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
