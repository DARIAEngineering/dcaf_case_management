Rails.application.routes.draw do
  authenticate :user do
    root to: 'dashboards#index', as: :authenticated_root
    get 'dashboard', to: 'dashboards#index', as: 'dashboard'
    get 'reports', to: 'reports#index', as: 'reports'
    post 'search', to: 'dashboards#search', defaults: { format: :js }
    resources :users, only: [:new, :create, :index]

    # Patient routes
    # /patients/:id/edit
    # /patients/:id/calls
    # /patients/:id/notes
    # /patients/:id/external_pledges
    resources :patients,
              only: [ :create, :edit, :update, :index ] do
      member do
        get :download, as: 'generate_pledge'
      end
      resources :calls,
                only: [ :create, :destroy, :new ]
      resources :notes,
                only: [ :create, :update ]
      resources :external_pledges,
                only: [ :create, :update, :destroy ]
    end
    get 'patients/:patient_id/submit_pledge', to: 'patients#pledge', as: 'submit_pledge'
    get 'data_entry', to: 'patients#data_entry', as: 'data_entry' # temporary
    post 'data_entry', to: 'patients#data_entry_create', as: 'data_entry_create' # temporary
    resources :accountants, only: [:index]
    get 'accountant', to: 'accountants#index', as: 'accountant'
    post 'accountant/search', to: 'accountants#search', defaults: { format: :js }
    patch 'users/:user_id/add_patient/:id', to: 'users#add_patient', as: 'add_patient', defaults: { format: :js }
    patch 'users/:user_id/remove_patient/:id', to: 'users#remove_patient', as: 'remove_patient', defaults: { format: :js }
    patch 'users/reorder_call_list', to: 'users#reorder_call_list', as: 'reorder_call_list', defaults: { format: :js }
    resources :lines, only: [:new, :create]
    get 'clinicfinder', to: 'clinicfinders#index', as: 'clinicfinder'
    post 'clinicfinder', to: 'clinicfinders#search', defaults: { format: :js } #, as: 'clinicfinder'
    resources :clinics, only: [:index, :create, :update, :new, :destroy, :edit]
  end

  # Auth routes
  root :to => redirect('/users/sign_in')
  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" },
                     skip: [:registrations]
  as :user do
    get '/users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put '/users' => 'devise/registrations#update', as: 'registration'
  end
end
