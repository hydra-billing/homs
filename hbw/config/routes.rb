HBW::Engine.routes.draw do
  defaults format: :json do
    resources :tasks, only: [:index] do
      put :form, on: :member, action: :submit
      get :lookup, on: :member
      post :claim, on: :member, action: :claim
    end

    get 'tasks/claiming', to: 'tasks#claiming'
    get 'tasks/list', to: 'tasks#list'
    get 'tasks/count', to: 'tasks#count'

    resources :buttons, only: [:index, :create]

    resources :users, only: [:index] do
      get :lookup, on: :collection, action: :lookup
      get :check, on: :collection, action: :check_user
    end

    post 'file_upload', to: 'files#upload'
  end
end
