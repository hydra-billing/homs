require 'api_constraints'

Rails.application.routes.draw do
  devise_for :users, controllers: {
               registrations: 'registrations',
               sessions: 'sessions'
             }

  get '/sign_in_by_token/:token' => 'sessions#sign_in_by_token'

  root to: 'orders#index', as: :list_orders

  resources :users do
    post :add, on: :collection
    get :lookup, on: :collection
    put :generate_api_token, on: :member
    delete :clear_api_token, on: :member
  end

  get '/orders/search_by/:field',
      to: 'orders#search_by',
      as: :search_order_by,
      constraints: { field: /code|ext_code/ }

  resources :orders, only: [:show, :edit, :update, :index, :new, :create]

  namespace :imprint do
    resources :prints, only: [] do
      get :print, on: :collection
      post :print_task, on: :collection
    end
  end

  namespace :admin do
    resources :order_types, only: [:index, :show, :create, :destroy] do
      get :lookup, on: :collection
      put :activate, on: :member
      delete :dismiss,  on: :member
    end
  end

  namespace :api, defaults: { format: :json } do
    scope module: :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      actions = [:index, :show, :create, :update, :destroy]

      resources :users, only: actions, constraints: { id: /.*/ }
      resources :orders, only: actions
    end
  end

  mount HBW::Engine => '/widget', as: :hbw
end
