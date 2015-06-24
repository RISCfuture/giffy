Rails.application.routes.draw do
  post '/giffy' => 'giffy#search'
  post '/latex' => 'latex#display'
  post '/glare' => 'other#glare'
end
