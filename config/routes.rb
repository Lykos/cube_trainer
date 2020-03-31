Rails.application.routes.draw do
  get 'timer/index'
  post 'timer/next_input'
  post 'timer/stop'
  post 'timer/delete'
  post 'timer/drop_input'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
