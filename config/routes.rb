Rails.application.routes.draw do

  authenticate :user do
    root to: 'dashboards#index', as: :authenticated_root
    get 'dashboard', to: 'dashboards#index', as: 'dashboard'
    get  'report', to: 'reports#index', as: 'report'
    post 'search', to: 'dashboards#search', defaults: { format: :js }
    resources :patients, only: [ :create, :edit, :update ] do
      resources :calls, only: [ :create ]
      resources :notes, only: [ :create, :update ]
      resources :pledges, only: [ :create, :update ]
    end
    patch 'users/:user_id/add_patient/:id', to: 'users#add_patient', as: 'add_patient', defaults: { format: :js }
    patch 'users/:user_id/remove_patient/:id', to: 'users#remove_patient', as: 'remove_patient', defaults: { format: :js }
    patch 'users/reorder_call_list', to: 'users#reorder_call_list', as: 'reorder_call_list', defaults: { format: :js }
  end
  root :to => redirect('/users/sign_in')
  resources :users, only: [:new, :create]
  devise_for :users, skip: [:registrations]
  as :user do
    get '/users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put '/users' => 'devise/registrations#update', as: 'registration'
  end
end
