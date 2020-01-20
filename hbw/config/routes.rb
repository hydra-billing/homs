HBW::Engine.routes.draw do
  defaults format: :json do
    get 'tasks/claiming', to: 'tasks#claiming'
    get 'tasks/list', to: 'tasks#list'
    get 'tasks/count', to: 'tasks#count'

    resources :tasks, only: [:index, :show] do
      put :form, on: :member, action: :submit
      get :lookup, on: :member
      post :claim, on: :member, action: :claim
    end

    resources :buttons, only: [:index, :create]

    resources :users, only: [:index] do
      get :lookup, on: :collection, action: :lookup
      get :check, on: :collection, action: :check_user
    end

    post 'file_upload', to: 'files#upload'

    namespace :events do
      resources :tasks, only: [:update]
    end
  end
end
