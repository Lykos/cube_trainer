Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope '/api' do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
                                  registrations: 'auth_overrides/registrations',
                                  sessions: 'auth_overrides/sessions'
                                }
    get 'name_or_email_exists', to: 'users#name_or_email_exists?'
    post 'confirm_email', to: 'users#confirm_email'
    get 'training_session_name_exists_for_user', to: 'training_sessions#name_exists_for_user?'
    resources :training_session_types, only: [:index, :show]
    resources :achievements, only: [:index, :show]
    resource :color_scheme, only: [:create, :show, :update, :destroy]
    resource :letter_scheme, only: [:create, :show, :update, :destroy]
    resources :messages, only: [:index, :create, :show, :update, :destroy]
    resources :achievement_grants, only: [:index, :show]
    resource :user
    resource :dump, only: [:show]
    resources :training_sessions do
      resources :results
      resources :alg_overrides
      post 'alg_overrides/create_or_update', to: 'alg_overrides#create_or_update'
    end
    resources :part_types, only: [:index]
  end
  # We don't need this in development because we use a separate server for the frontend via `npm start`.
  # It's useful because it frees up the possibility to access internal rails URLs.
  get '*other', to: 'index#index' unless Rails.env.development?
end
