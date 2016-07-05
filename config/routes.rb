Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  post '/giffy' => 'giffy#search'
  post '/latex' => 'latex#display'
  post '/glare' => 'other#glare'
end
