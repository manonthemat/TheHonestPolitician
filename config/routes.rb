TheHonestPolitician::Application.routes.draw do
  root 'representatives#index'
  resources :representatives
  match '/checkAddress' => 'representatives#checkAddress', via: [:get, :post]
  match '/getRepID' => 'representatives#getRepresentativesID', via: [:get, :post]
end
