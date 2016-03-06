Rails.application.routes.draw do
  authenticate :user do
    root to: 'pregnancies#index', as: :authenticated_root
    resources :pregnancies do
      member do
        resources :calls, only: [ :create ]
      end
    end
    resources :patients, only: [ :create ]
    patch 'users/:user_id/add_pregnancy/:id', to: 'users#add_pregnancy'
    patch 'users/:user_id/remove_pregnancy/:id', to: 'users#remove_pregnancy'
    post 'search', to: 'pregnancies#search'
  end
  root :to => redirect('/users/sign_in')
  devise_for :users
end
