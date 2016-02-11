Rails.application.routes.draw do
  authenticate :user do
    root to: 'cases#index', as: :authenticated_root
    resources :cases do
      member do
        resources :calls, only: [ :create ]
      end
    end
    resources :patients, only: [ :create ]
  end
  root :to => redirect('/users/sign_in')
  devise_for :users
  patch 'users/:user_id/add_case/:id', to: 'users#add_case'
  patch 'users/:user_id/remove_case/:id', to: 'users#remove_case'
end
