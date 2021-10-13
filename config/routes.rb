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

  delete '/users/identifiers/:id', to: 'identifiers#destroy', as: 'destroy_user_identifier'

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
  get 'about_us', to: 'static/static_pages#show', name: 'about_us'
  get 'help', to: 'static/static_pages#show', name: 'help'
  get 'roadmap', to: 'static/static_pages#show', name: 'roadmap'
  get 'terms', to: 'static/static_pages#show', name: 'termsuse'
  get 'privacy', to: 'static/static_pages#show', name: 'privacy'
  get 'research_output_types', to: 'static/static_pages#show', name: 'research_output_types'
  get "about_registries", to: "static/static_pages#show", name: "about_registries"

  get "tutorials", to: 'static_pages#tutorials'
  get "news_feed", to: 'static_pages#news_feed'
  get "optout", to: 'static_pages#optout'
  get "public_plans" => 'public_pages#plan_index'
  get "public_templates" => 'public_pages#template_index'
  get "template_export/:id" => 'public_pages#template_export', as: 'template_export'

  # AJAX call used to search for Orgs based on user input into autocompletes
  post "orgs" => "orgs#search", as: "orgs_search"

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
    post 'set_answers_as_common', on: :collection
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

    resources :contributors, except: %i[show]

    member do
      get 'answer'
      get 'share'
      get 'request_feedback'
      get 'download'
      get 'budget'
      post 'duplicate'
      post 'visibility', constraints: {format: [:json]}
      post 'set_test', constraints: {format: [:json]}
    end
    resources :research_outputs, only: [:index, :update, :destroy], controller: 'research_outputs'
  end

  resources :research_outputs, only: [] do
    get "create_remote", on: :collection
    post "sort", on: :collection
  end

  resources :madmp_fragments, only: [:create, :update, :destroy] do
    get "load_new_form", action: :load_form, on: :collection
    get "load_form/:id", action: :load_form, on: :collection
    get "change_schema/:id", action: :change_schema, on: :collection
    get "new_edit_linked", on: :collection, constraints: { format: [:js] }
    get "show_linked", on: :collection, constraints: { format: [:js] }
    get "create_from_registry", action: :create_from_registry_value, on: :collection
    get "create_contributor", action: :create_contributor, on: :collection
    delete "destroy_contributor", action: :destroy_contributor, on: :collection
    get "load_fragments", action: :load_fragments, on: :collection
  end

  resources :registries, only: [] do
    get "load_values", action: :load_values, on: :collection
  end

  get "/codebase/run", to: "madmp_codebase#run", constraints: { format: [:json] }
  get "/codebase/anr_search", to: "madmp_codebase#anr_search", constraints: { format: [:json] }

  resources :research_outputs, only: [] do
    post "sort", on: :collection
  end

  resources :usage, only: [:index]
  post 'usage_plans_by_template', controller: 'usage', action: 'plans_by_template'
  get 'usage_all_plans_by_template', controller: 'usage', action: 'all_plans_by_template'
  get 'usage_global_statistics', controller: 'usage', action: 'global_statistics'
  get 'usage_org_statistics', controller: 'usage', action: 'org_statistics'
  get 'usage_yearly_users', controller: 'usage', action: 'yearly_users'
  get 'usage_yearly_plans', controller: 'usage', action: 'yearly_plans'

  resources :usage_downloads, only: [:index]

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
      resources :departments, only: [:create, :index] do
        collection do
          get :users
          patch :unassign_users
        end
        member do
          patch :assign_users
        end
      end
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
      resources :themes, param: :slug, only: [] do
        member do
          get 'extract', to: 'themes#extract'
        end
      end
      namespace :madmp do
        resources :dmp_fragments, controller: "madmp_fragments", action: "dmp_fragments"
        resources :madmp_fragments, only: [:show, :update], controller: "madmp_fragments", path: "fragments"
        resources :madmp_schemas, only: [:show], controller: "madmp_schemas", path: "schemas"
        resources :plans, only: [:show] do
          member do
            get :rda_export
          end
        end
      end
    end

    namespace :v1 do
      get :heartbeat, controller: "base_api"
      post :authenticate, controller: "authentication"

      resources :plans, only: [:create, :show, :index]
      resources :templates, only: [:index]

      namespace :madmp do
        resources :dmp_fragments, controller: "madmp_fragments", action: "dmp_fragments"
        resources :madmp_fragments, only: [:show, :update], controller: "madmp_fragments", path: "fragments"
        resources :madmp_schemas, only: [:index, :show], controller: "madmp_schemas", path: "schemas"
        resources :plans, only: [:show] do
          member do
            get :rda_export
          end
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
      get 'administrator_visible/:page', action: :administrator_visible, on: :collection, as: :administrator_visible
      get 'privately_visible/:page', action: :privately_visible, on: :collection, as: :privately_visible
      get 'organisationally_or_publicly_visible/:page', action: :organisationally_or_publicly_visible, on: :collection, as: :organisationally_or_publicly_visible
      get 'publicly_visible/:page', action: :publicly_visible, on: :collection, as: :publicly_visible
      get 'org_admin/:page', action: :org_admin, on: :collection, as: :org_admin
      get 'org_admin_other_user/:page', action: :org_admin_other_user, on: :collection, as: :org_admin_other_user

      # Paginable actions for contributors
      resources :contributors, only: %i[index] do
        get "index/:page", action: :index, on: :collection, as: :index
      end
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
    # Paginable actions for static pages
    resources :static_pages, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for departments
    resources :departments, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for madmp schemas
    resources :madmp_schemas, only: [] do
      get "index/:page", action: :index, on: :collection, as: :index
    end
    # Paginable actions for registries
    resources :registries, only: [] do
      get "index/:page", action: :index, on: :collection, as: :index
    end
    # Paginable actions for registry values
    resources :registry_values, only: [] do
      get ":id/index/:page", action: :index, on: :collection, as: :index
    end
    # Paginable actions for api_clients
     resources :api_clients, only: [] do
       get 'index/:page', action: :index, on: :collection, as: :index
     end
  end

  resources :template_options, only: [:index], constraints: { format: /json/ }

  # ORG ADMIN specific pages
  namespace :org_admin do
    resources :users, only: [:edit, :update], controller: "users" do
      member do
        get 'user_plans'
      end
    end

    resources :question_options, only: [:destroy], controller: "question_options"

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
    resources :madmp_schemas, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :registries do
      post "sort_values", on: :collection
      get "download"
    end
    resources :registry_values, only: [:new, :create, :edit, :update, :destroy]
    resources :users, only: [:edit, :update] do
      member do
        put :merge
        put :archive
        get :search
      end
    end

    resources :notifications, except: [:show] do
      member do
        post 'enable', constraints: {format: [:json]}
      end
    end
    resources :static_pages

    resources :api_clients do
       member do
         get :email_credentials
         get :refresh_credentials
       end
     end
  end


  # Static pages
  namespace :static do
    get ':name', to: 'static_pages#show'
  end

  get "research_projects/search", action: "search",
                                  controller: "research_projects",
                                  constraints: { format: "json" }

  get "research_projects/(:type)", action: "index",
                                   controller: "research_projects",
                                   constraints: { format: "json" }



end
