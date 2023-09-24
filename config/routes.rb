Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ('/')
  # root 'articles#index'

  root 'games#index'

  resources :games, only: [:index, :show] do
    scope module: :games do
      resources :maps, class: 'Games::MapsController', only: [:index, :show] do
        get 'initial'
      end
    end
  end

  namespace :games do
  end
end
