Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ('/')
  # root 'articles#index'

  root 'games#index'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    unlocks: 'users/unlocks'
  }
  devise_scope :user do
    delete '/users/sign_out' => 'devise/sessions#destroy'
  end

  resources :games, only: [:index, :show] do
    resources :turns, only: [:index, :show], controller: 'games/turns'
  end
end
