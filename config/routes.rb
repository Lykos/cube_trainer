Rails.application.routes.draw do
  get 'timer/index'
  post 'timer/start'
  post 'timer/stop'
  post 'timer/delete'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
