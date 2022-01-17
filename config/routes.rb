require 'api_constraints'

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'registrations',
    sessions:      'sessions',
    omniauth_callbacks: 'omniauth_callbacks'
  }

  # devise_scope :user do
  #   delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  # end

  get '/sign_in_by_token/:token' => 'sessions#sign_in_by_token'

  root to: 'orders#index'

  resources :users do
    post :add, on: :collection
    get :lookup, on: :collection
    put :generate_api_token, on: :member
    delete :clear_api_token, on: :member
  end

  get '/orders/search_by/:field',
      to:          'orders#search_by',
      as:          :search_order_by,
      constraints: {field: /code|ext_code/}

  get '/orders/order_type_attributes/:id' => 'orders#get_order_type_attributes'

  get '/orders/list', to: 'orders#list'

  get '/tasks', to: 'tasks#index'

  resources :orders, only: [:show, :edit, :update, :index, :new, :create]

  resources :profiles, only: [:create, :update]

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
      delete :dismiss, on: :member
    end
  end

  namespace :api, defaults: {format: :json} do
    scope module:      :v1,
          constraints: ApiConstraints.new(version: 1, default: true) do
      actions = [:index, :show, :create, :update, :destroy]

      resources :users, only: actions, constraints: {id: /.*/}
      resources :orders, only: actions
      resources :profiles, only: actions
    end
  end

  mount HBW::Engine => '/widget', as: :hbw
end
