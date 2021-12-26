Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope '/api' do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
                                  registrations: 'auth_overrides/registrations',
                                  sessions: 'auth_overrides/sessions'
                                }
    get 'name_or_email_exists', to: 'users#name_or_email_exists?'
    post 'confirm_email', to: 'users#confirm_email'
    get 'mode_name_exists_for_user', to: 'modes#name_exists_for_user?'
    resources :mode_types, only: [:index, :show]
    resources :achievements, only: [:index, :create, :show, :update, :destroy]
    resource :color_scheme, only: [:create, :show, :update, :destroy]
    resource :letter_scheme, only: [:create, :show, :update, :destroy]
    resources :messages, only: [:index, :create, :show, :update, :destroy]
    resources :achievement_grants, only: [:index, :show]
    resource :user
    resource :dump, only: [:show]
    resources :modes do
      resources :cases, only: [:index, :show]
      resources :results
      resources :stats, only: [:index, :show, :destroy]
    end
    resources :stat_types, only: [:index, :show]
    get 'trainer/:mode_id/random_case', to: 'trainer#random_case'
    get 'trainer/:mode_id/inputs/:input_id/image/:img_side', to: 'cube_images#show'
    resources :part_types, only: [:index]
  end
  # We don't need this in development because we use a separate server for the frontend via `npm start`.
  # It's useful because it frees up the possibility to access internal rails URLs.
  get '*other', to: 'index#index' unless Rails.env.development?
end
