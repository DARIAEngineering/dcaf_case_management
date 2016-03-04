Rails.application.routes.draw do
  authenticate :user do
    root to: 'pregnancy_cases#index', as: :authenticated_root
    resources :pregnancy_cases do
      member do
        resources :calls, only: [ :create ]
      end
    end
    resources :patients, only: [ :create ]
    patch 'users/:user_id/add_case/:id', to: 'users#add_case'
    patch 'users/:user_id/remove_case/:id', to: 'users#remove_case'
    post 'search', to: 'pregnancy_cases#search'
  end
  root :to => redirect('/users/sign_in')
  devise_for :users
end
