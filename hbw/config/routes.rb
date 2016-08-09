HBW::Engine.routes.draw do
  defaults format: :json do
    resources :tasks, only: [:index] do
      get :form, on: :member, action: :edit
      put :form, on: :member, action: :submit
      get :lookup, on: :member
    end

    resources :buttons, only: [:index, :create]

    resources :users, only: [:index] do
      get :lookup, on: :collection, action: :lookup
      get :check, on: :collection, action: :check_user
    end
  end
end
