Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'authorize' => 'authorization_requests#create', as: :authorize
  resources :authorization_requests, only: :show

  post '/giffy' => 'giffy#search'
  post '/latex' => 'latex#display'
  post '/comicsans' => 'comic_sans#display'

  post 'interact' => 'interactions#handle'

  root 'authorization_requests#new'
  match '*path' => 'home#index', via: :all # Vue-Router handles all the front-end routing (routes.js)
end
