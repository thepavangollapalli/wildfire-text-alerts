Rails.application.routes.draw do
  resources :users, only: [:new, :create, :show]
  post 'users/delete', to: 'users#delete'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'users#new'
end
