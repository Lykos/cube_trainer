Rails.application.routes.draw do
  get 'signup', to: 'users#new'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'logout', to: 'sessions#logout'
  get 'welcome', to: 'sessions#welcome'
  root 'sessions#welcome'
  resources :mode_types, only: [:index, :show]
  resources :achievements
  resources :users do
    resources :messages
    resources :achievement_grants, only: [:index, :show]
  end
  resources :modes do
    resources :results, only: [:index, :show, :destroy]
  end
  get 'users/:user_id/unread_messages_count', to: 'messages#count_unread'
  get 'trainer/:mode_id', to: 'trainer#index'
  post 'trainer/:mode_id/inputs', to: 'trainer#create'
  delete 'trainer/:mode_id/inputs/:id', to: 'trainer#destroy'
  post 'trainer/:mode_id/inputs/:id', to: 'trainer#stop'
  get 'trainer/:mode_id/inputs/:input_id/image/:img_side', to: 'cube_images#show'
end
