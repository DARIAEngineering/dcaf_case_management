Rails.application.routes.draw do
  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" },
                     skip: [:registrations]
  authenticate :user do
    root to: 'dashboards#index', as: :authenticated_root
    get 'dashboard', to: 'dashboards#index', as: 'dashboard'
    get 'reports', to: 'reports#index', as: 'reports'
    get 'budget_bar', to: 'dashboards#budget_bar', defaults: { format: :js }, as: 'budget_bar'
    post 'search', to: 'dashboards#search', defaults: { format: :js }

    # For call list management
    patch 'call_lists/reorder_call_list', to: 'call_lists#reorder_call_list', as: 'reorder_call_list', defaults: { format: :js }
    patch 'call_lists/clear_current_user_call_list', to: 'call_lists#clear_current_user_call_list', as: 'clear_current_user_call_list', defaults: { format: :js }
    patch 'call_lists/add_patient/:id', to: 'call_lists#add_patient', as: 'add_patient', defaults: { format: :js }
    patch 'call_lists/remove_patient/:id', to: 'call_lists#remove_patient', as: 'remove_patient', defaults: { format: :js }

    # User REST routes and searching
    post 'users/search', to: 'users#search', as: 'users_search', defaults: { format: :js }
    resources :users, only: [:new, :create, :index, :edit, :update]

    # For user management
    patch 'users/:id/change_role_to_admin', to: 'users#change_role_to_admin', as: 'change_role_to_admin'
    patch 'users/:id/change_role_to_data_volunteer', to: 'users#change_role_to_data_volunteer', as: 'change_role_to_data_volunteer'
    patch 'users/:id/change_role_to_cm', to: 'users#change_role_to_cm', as: 'change_role_to_cm'
    post 'users/:id/toggle_disabled', to: 'users#toggle_disabled', as: 'toggle_disabled'

    # Patient routes
    # /patients/:id/edit
    # /patients/:id/calls
    # /patients/:id/notes
    # /patients/:id/external_pledges
    # /patients/:id/practical_supports
    resources :patients,
              only: [ :create, :edit, :update, :index, :destroy ] do
      member do
        get :download, as: 'generate_pledge'
      end
      resources :calls,
                only: [ :create, :destroy, :new ]
      resources :notes,
                only: [ :create, :update ]
      resources :external_pledges,
                only: [ :create, :update, :destroy ]
      resources :practical_supports,
                only: [ :create, :update, :destroy ]
    end

    get 'reports/:timeframe', to: 'reports#report', as: 'patients_report'

    get 'patients/:patient_id/submit_pledge', to: 'patients#pledge', as: 'submit_pledge'

    get 'data_entry', to: 'patients#data_entry', as: 'data_entry' # temporary
    post 'data_entry', to: 'patients#data_entry_create', as: 'data_entry_create' # temporary

    resources :accountants, only: [:index, :edit]
    post 'accountant/search', to: 'accountants#search', defaults: { format: :js }

    resources :lines, only: [:new, :create]
    post 'clinicfinder', to: 'clinicfinders#search', defaults: { format: :js }, as: 'clinicfinder_search'
    resources :clinics, only: [:index, :create, :update, :new, :destroy, :edit]
    resources :configs, only: [:index, :create, :update]
    resources :events, only: [:index]
  end

  # Auth routes
  root :to => redirect('/users/sign_in')
  as :user do
    get '/users/edit' => 'devise/registrations#edit', as: 'edit_user_registration'
    put '/users' => 'devise/registrations#update', as: 'registration'
  end
end
