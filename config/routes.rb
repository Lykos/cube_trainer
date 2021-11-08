Rails.application.routes.draw do
  scope '/api' do
    get 'signup', to: 'users#new'
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    post 'logout', to: 'sessions#logout'
    get 'welcome', to: 'sessions#welcome'
    root 'sessions#welcome'
    get 'username_or_email_exists', to: 'users#name_or_email_exists?'
    get 'mode_name_exists_for_user', to: 'modes#name_exists_for_user?'
    resources :mode_types, only: [:index, :show]
    resources :achievements
    get 'users/:user_id/messages/count_unread', to: 'messages#count_unread'
    resources :users do
      resources :messages
      resources :achievement_grants, only: [:index, :show]
    end
    resources :modes do
      resources :results, only: [:index, :show, :destroy, :update]
      resources :stats, only: [:index, :show, :destroy]
    end
    resources :stat_types, only: [:index, :show]
    get 'trainer/:mode_id', to: 'trainer#index'
    post 'trainer/:mode_id/inputs', to: 'trainer#create'
    delete 'trainer/:mode_id/inputs/:id', to: 'trainer#destroy'
    post 'trainer/:mode_id/inputs/:id', to: 'trainer#stop'
    get 'trainer/:mode_id/inputs/:input_id/image/:img_side', to: 'cube_images#show'
  end
  get '*other', to: 'index#index'
end
