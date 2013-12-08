TheHonestPolitician::Application.routes.draw do
  root 'representatives#index'
  resources :representatives
  match '/checkAddress' => 'representatives#checkAddress', via: [:get, :post]
  match '/getVotes' => 'representatives#getVotes', via: [:get, :post]
end
