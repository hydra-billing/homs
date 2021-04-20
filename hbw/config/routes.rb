HBW::Engine.routes.draw do
  defaults format: :json do
    resources :tasks, only: [:index, :show, :destroy] do
      put :form, on: :member, action: :submit
      get :lookup, on: :member
      post :claim, on: :member, action: :claim
      get :forms, on: :collection
    end

    resources :buttons, only: [:index, :create]

    resources :users, only: [:index] do
      get :lookup, on: :collection, action: :lookup
      get :check, on: :collection, action: :check_user
    end

    resources :translations, only: [:index]

    post 'files/upload', to: 'files#upload'
    post 'file_upload', to: 'files#upload' # [DEPRECATED]

    namespace :events do
      resources :tasks, only: [:update]
    end
  end
end
