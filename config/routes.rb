Rails.application.routes.draw do
  authenticate :user do
    root to: 'dashboards#index', as: :authenticated_root
    get 'dashboard', to: 'dashboards#index', as: 'dashboard'
    post 'search', to: 'dashboards#search', defaults: { format: :js }
    resources :pregnancies, only: [ :create, :edit, :update ] do
      resources :calls, only: [ :create ]
      resources :notes, only: [ :create, :update ]
      resources :pledges, only: [ :create, :update ]
    end
    patch 'users/:user_id/add_pregnancy/:id', to: 'users#add_pregnancy', as: 'add_pregnancy', defaults: { format: :js }
    patch 'users/:user_id/remove_pregnancy/:id', to: 'users#remove_pregnancy', as: 'remove_pregnancy', defaults: { format: :js }
  end
  root :to => redirect('/users/sign_in')
  devise_for :users, skip: [:registrations]
  as :user do
    get '/users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put '/users' => 'devise/registrations#update', as: 'registration'
  end
end
