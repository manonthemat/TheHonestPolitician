TheHonestPolitician::Application.routes.draw do
  root 'representatives#index'
  resources :representatives
  get '/todo' => 'representatives#todo'
end
