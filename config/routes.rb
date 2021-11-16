Rails.application.routes.draw do
  scope '/api' do
    mount_devise_token_auth_for 'User', at: 'auth'
    post 'login', to: 'sessions#create'
    post 'logout', to: 'sessions#logout'
    root 'sessions#welcome'
    get 'username_or_email_exists', to: 'users#name_or_email_exists?'
    post 'confirm_email', to: 'users#confirm_email'
    get 'mode_name_exists_for_user', to: 'modes#name_exists_for_user?'
    resources :mode_types, only: [:index, :show]
    resources :achievements, only: [:index, :create, :show, :update, :destroy]
    resource :color_scheme, only: [:create, :show, :update, :destroy]
    resource :letter_scheme, only: [:create, :show, :update, :destroy]
    get 'users/:user_id/messages/count_unread', to: 'messages#count_unread'
    resources :users do
      resources :messages, only: [:index, :create, :show, :update, :destroy]
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
    resources :part_types, only: [:index]
  end
  # We don't need this in development because we use a separate server for the frontend via `npm start`.
  # It's useful because it frees up the possibility to access internal rails URLs.
  get '*other', to: 'index#index' unless Rails.env.development?
end
