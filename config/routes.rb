Rails.application.routes.draw do

  devise_for( :users, controllers: {
    registrations: "registrations",
    passwords: 'passwords',
    sessions: 'sessions',
    omniauth_callbacks: 'users/omniauth_callbacks',
    invitations: 'users/invitations'
    }) do

    get "/users/sign_out", :to => "devise/sessions#destroy"
  end

  delete '/users/identifiers/:id', to: 'user_identifiers#destroy', as: 'destroy_user_identifier'

  get '/orgs/shibboleth', to: 'orgs#shibboleth_ds', as: 'shibboleth_ds'
  get '/orgs/shibboleth/:org_name', to: 'orgs#shibboleth_ds_passthru'
  post '/orgs/shibboleth', to: 'orgs#shibboleth_ds_passthru'

  resources :users, path: 'users', only: [] do

    resources :org_swaps, only: [:create],
                          controller: "super_admin/org_swaps"

    member do
      put 'update_email_preferences'
    end

    post '/acknowledge_notification', to: 'users#acknowledge_notification'

  end

  #organisation admin area
  resources :users, :path => 'org/admin/users', only: [] do
    collection do
      get 'admin_index'
    end
    member do
      get 'admin_grant_permissions'
      put 'admin_update_permissions'
      put 'activate'
    end
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  patch 'locale/:locale' => 'session_locales#update', as: 'locale'

  root :to => 'home#index'
  get "about_us" => 'static_pages#about_us'
  get "help" => 'static_pages#help'
  get "roadmap" => 'static_pages#roadmap'
  get "terms" => 'static_pages#termsuse'
  get "privacy" => 'static_pages#privacy'
  get "public_plans" => 'public_pages#plan_index'
  get "public_templates" => 'public_pages#template_index'
  get "template_export/:id" => 'public_pages#template_export', as: 'template_export'

  #post 'contact_form' => 'contacts', as: 'localized_contact_creation'
  #get 'contact_form' => 'contacts#new', as: 'localized_contact_form'

  resources :orgs, :path => 'org/admin', only: [] do
    member do
      get 'admin_edit'
      put 'admin_update'
    end
    resources :departments, controller: 'org_admin/departments'
  end

  resources :guidances, :path => 'org/admin/guidance', only: [] do
    member do
      get 'admin_index'
      get 'admin_edit'
      get 'admin_new'
      delete 'admin_destroy'
      post 'admin_create'
      put 'admin_update'
      put 'admin_publish'
      put 'admin_unpublish'
    end
  end

  resources :guidance_groups, :path => 'org/admin/guidancegroup', only: [] do
    member do
      get 'admin_show'
      get 'admin_new'
      get 'admin_edit'
      delete 'admin_destroy'
      post 'admin_create'
      put 'admin_update'
      put 'admin_update_publish'
      put 'admin_update_unpublish'
    end
  end

  resources :answers, only: [] do
    post 'create_or_update', on: :collection
  end

  # Question Formats controller, currently just the one action
  get 'question_formats/rda_api_address' => 'question_formats#rda_api_address'

  resources :notes, only: [:create, :update, :archive] do
    member do
      patch 'archive'
    end
  end

  resources :feedback_requests, only: [:create]

  resources :plans do

    resource :export, only: [:show], controller: "plan_exports"

    member do
      get 'answer'
      get 'share'
      get 'request_feedback'
      get 'download'
      post 'duplicate'
      post 'visibility', constraints: {format: [:json]}
      post 'set_test', constraints: {format: [:json]}
      get 'overview'
    end
  end

  resources :usage, only: [:index]

  resources :usage_downloads, only: [:index]

  resources :stat_created_plans_by_template, only: [:index]

  resources :roles, only: [:create, :update, :destroy] do
    member do
      put :deactivate
    end
  end

  namespace :settings do
    resources :plans, only: [:update]
  end

  namespace :api, defaults: {format: :json} do
    namespace :v0 do
      resources :guidances, only: [:index], controller: 'guidance_groups', path: 'guidances'
      resources :plans, only: [:create, :index]
      resources :templates, only: :index
      resource  :statistics, only: [], controller: "statistics", path: "statistics" do
        member do
          get :users_joined
          get :completed_plans
          get :created_plans
          get :using_template
          get :plans_by_template
          get :plans
        end
      end
    end
  end

  namespace :paginable do
    resources :orgs, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for plans
    resources :plans, only: [] do
      get 'privately_visible/:page', action: :privately_visible, on: :collection, as: :privately_visible
      get 'organisationally_or_publicly_visible/:page', action: :organisationally_or_publicly_visible, on: :collection, as: :organisationally_or_publicly_visible
      get 'publicly_visible/:page', action: :publicly_visible, on: :collection, as: :publicly_visible
      get 'org_admin/:page', action: :org_admin, on: :collection, as: :org_admin
      get 'org_admin_other_user/:page', action: :org_admin_other_user, on: :collection, as: :org_admin_other_user
    end
    # Paginable actions for users
    resources :users, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for themes
    resources :themes, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for notifications
    resources :notifications, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for templates
    resources :templates, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
      get 'customisable/:page', action: :customisable, on: :collection, as: :customisable
      get 'organisational/:page', action: :organisational, on: :collection, as: :organisational
      get 'publicly_visible/:page', action: :publicly_visible, on: :collection, as: :publicly_visible
      get ':id/history/:page', action: :history, on: :collection, as: :history
    end
    # Paginable actions for guidances
    resources :guidances, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for guidance_groups
    resources :guidance_groups, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for departments
    resources :departments, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
  end

  resources :template_options, only: [:index], constraints: { format: /json/ }

  # ORG ADMIN specific pages
  namespace :org_admin do
    resources :users, only: [:edit, :update], controller: "users" do
      member do
        get 'user_plans'
    resources :questions, only: [] do
      get 'open_conditions'
      resources :conditions, only: [:new, :show] do
      end
    end
    resources :plans, only: [:index] do
      member do
        get 'feedback_complete'
      end
    end


    resources :templates do

      resources :customizations, only: [:create], controller: "template_customizations"

      resources :copies, only: [:create],
      controller: "template_copies",
      constraints: { format: [:json] }

      resources :customization_transfers, only: [:create],
      controller: "template_customization_transfers"

      member do
        get 'history'
        get 'template_export',  action: :template_export
        patch 'publish', action: :publish, constraints: {format: [:json]}
        patch 'unpublish', action: :unpublish, constraints: {format: [:json]}
      end

      # Used for the organisational and customizable views of index
      collection do
        get 'organisational'
        get 'customisable'
      end

      resources :phases, except: [:index] do

        resources :versions, only: [:create], controller: "phase_versions"

        member do
          get 'preview'
          post 'sort'
        end

        resources :sections, only: [:index, :show, :edit, :update, :create, :destroy] do
          resources :questions, only: [:show, :edit, :new, :update, :create, :destroy] do
          end
        end
      end
    end

    get 'download_plans' => 'plans#download_plans'

  end

  namespace :super_admin do
    resources :orgs, only: [:index, :new, :create, :destroy]
    resources :themes, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :users, only: [:edit, :update] do
      member do
        put :merge
        put :archive
        get :search
      end
    end
    resources :notifications, except: [:show]
  end

  get "research_projects/search", action: "search",
                                  controller: "research_projects",
                                  constraints: { format: "json" }

  get "research_projects/(:type)", action: "index",
                                   controller: "research_projects",
                                   constraints: { format: "json" }



end
