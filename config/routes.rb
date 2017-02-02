Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'authorization_requests#new'
  get 'authorize' => 'authorization_requests#create', as: :authorize
  resources :authorization_requests, only: :show

  post '/giffy' => 'giffy#search'
  post '/latex' => 'latex#display'
end
