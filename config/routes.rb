Rails.application.routes.draw do
  authenticate :user do
    root to: 'pregnancies#index', as: :authenticated_root
    resources :pregnancies do
      member do
        resources :calls, only: [ :create ]
      end
    end
    resources :patients, only: [ :create ]
  end
  root :to => redirect('/users/sign_in')
  devise_for :users
end
