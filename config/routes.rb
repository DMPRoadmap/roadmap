Rails.application.routes.draw do
  namespace :admin do
    resources :users,              only: [:new, :create, :edit, :update, :index, :show]
    resources :orgs,               only: [:new, :create, :edit, :update, :index, :show]
    resources :perms,              only: [:new, :create, :edit, :update, :index, :show]
    resources :languages,          only: [:new, :create, :edit, :update, :index, :show]
    resources :templates,          only: [:new, :create, :edit, :update, :index, :show]
    resources :phases,             only: [:new, :create, :edit, :update, :index, :show]
    resources :sections,           only: [:new, :create, :edit, :update, :index, :show]
    resources :questions,          only: [:new, :create, :edit, :update, :index, :show]
    resources :question_formats,   only: [:new, :create, :edit, :update, :index, :show]
    resources :question_options,   only: [:new, :create, :edit, :update, :index, :show]
    resources :annotations,        only: [:new, :create, :edit, :update, :index, :show]
    resources :answers,            only: [:new, :create, :edit, :update, :index, :show]
    resources :guidances,          only: [:new, :create, :edit, :update, :index, :show]
    resources :guidance_groups,    only: [:new, :create, :edit, :update, :index, :show]
    resources :themes,             only: [:new, :create, :edit, :update, :index, :show]
    resources :notes,              only: [:new, :create, :edit, :update, :index, :show]
    resources :plans,              only: [:new, :create, :edit, :update, :index, :show]
    resources :identifier_schemes, only: [:new, :create, :edit, :update, :index, :show]
    resources :exported_plans,     only: [:new, :create, :edit, :update, :index, :show]
    resources :regions,            only: [:new, :create, :edit, :update, :index, :show]
    resources :roles,              only: [:new, :create, :edit, :update, :index, :show]
    resources :splash_logs,        only: [:new, :create, :edit, :update, :index, :show]
    resources :user_identifiers,   only: [:new, :create, :edit, :update, :index, :show]
resources :token_permission_types, only: [:new, :create, :edit, :update, :index, :show]
#resources :plans_guidance_groups

    root to: "users#index"
  end

  devise_for :users, controllers: {
        registrations: "registrations",
        passwords: 'passwords',
        sessions: 'sessions',
        omniauth_callbacks: 'users/omniauth_callbacks',
        invitations: 'users/invitations' } do

    get "/users/sign_out", :to => "devise/sessions#destroy"
  end


  # WAYFless access point - use query param idp
  #get 'auth/shibboleth' => 'users/omniauth_shibboleth_request#redirect', :as => 'user_omniauth_shibboleth'
  #get 'auth/shibboleth/assoc' => 'users/omniauth_shibboleth_request#associate', :as => 'user_shibboleth_assoc'
  #post '/auth/:provider/callback' => 'sessions#oauth_create'

  # fix for activeadmin signout bug
  devise_scope :user do
    delete '/users/sign_out' => 'devise/sessions#destroy'
  end

  delete '/users/identifiers/:id', to: 'user_identifiers#destroy', as: 'destroy_user_identifier'

  get '/orgs/shibboleth', to: 'orgs#shibboleth_ds', as: 'shibboleth_ds'
  get '/orgs/shibboleth/:org_name', to: 'orgs#shibboleth_ds_passthru'
  post '/orgs/shibboleth', to: 'orgs#shibboleth_ds_passthru'

  resources :users, path: 'users', only: [] do
    member do
      put 'update_email_preferences'
      put 'org_swap', constraints: {format: [:json]}
    end
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

  patch 'locale/:locale' => 'application#set_locale_session', as: 'locale'

  root :to => 'home#index'
    get "about_us" => 'static_pages#about_us'
    get "help" => 'static_pages#help'
    get "roadmap" => 'static_pages#roadmap'
    get "terms" => 'static_pages#termsuse'
    get "public_plans" => 'public_pages#plan_index'
    get "public_templates" => 'public_pages#template_index'
    get "template_export/:id" => 'public_pages#template_export', as: 'template_export'
    get "plan_export/:id" => 'public_pages#plan_export', as: 'plan_export'
    get "existing_users" => 'existing_users#index'

    #post 'contact_form' => 'contacts', as: 'localized_contact_creation'
    #get 'contact_form' => 'contacts#new', as: 'localized_contact_form'

    resources :orgs, :path => 'org/admin', only: [] do
      member do
        get 'children'
        get 'templates'
        get 'admin_show'
        get 'admin_edit'
        put 'admin_update'
      end
    end

    resources :guidances, :path => 'org/admin/guidance', only: [] do
      member do
        get 'admin_show'
        get 'admin_index'
        get 'admin_edit'
        get 'admin_new'
        delete 'admin_destroy'
        post 'admin_create'
        put 'admin_update'
        put 'admin_publish'
        put 'admin_unpublish'
        get 'update_phases'
        get 'update_versions'
        get 'update_sections'
        get 'update_questions'
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

    resources :plans do
      member do
        get 'status'
        get 'locked'
        get 'answer'
        put 'update_guidance_choices'
        post 'delete_recent_locks'
        post 'lock_section', constraints: {format: [:html, :json]}
        post 'unlock_section', constraints: {format: [:html, :json]}
        post 'unlock_all_sections'
        get 'warning'
        get 'section_answers'
        get 'share'
        get 'download'
        post 'duplicate'
        get 'export'
        post 'invite'
        post 'visibility', constraints: {format: [:json]}
        post 'set_test', constraints: {format: [:json]}
        get 'request_feedback'
        get 'overview'
        get 'phase_status'
      end

      collection do
        get 'possible_templates'
        get 'possible_guidance'
      end
    end

    resources :usage, only: [:index]

    resources :roles, only: [:create, :update, :destroy] do
      member do
        put :deactivate
      end
    end

    namespace :settings do
      resources :plans, only: [:update]
    end

    resources :token_permission_types, only: [:index]

    namespace :api, defaults: {format: :json} do
      namespace :v0 do
        resources :guidances, only: [:index], controller: 'guidance_groups', path: 'guidances'
        resources :plans, only: :create
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
      end
      # Paginable actions for users
      resources :users, only: [] do
        get 'index/:page', action: :index, on: :collection, as: :index
      end
      # Paginable actions for themes
      resources :themes, only: [] do
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
    end

    # ORG ADMIN specific pages
    namespace :org_admin do
      resources :plans, only: [:index] do
        member do
          get 'feedback_complete'
        end
      end
      resources :templates, only: [:index, :show, :new, :edit, :create, :update, :destroy] do
        member do
          get 'history'
          post 'customize'
          post 'transfer_customization'
          post 'copy', action: :copy, constraints: {format: [:json]}
          patch 'publish', action: :publish, constraints: {format: [:json]}
          patch 'unpublish', action: :unpublish, constraints: {format: [:json]}
        end
        
        # Used for the organisational and customizable views of index
        collection do
          get 'organisational'
          get 'customisable'
        end
        
        resources :phases, only: [:show, :edit, :new, :create, :edit, :update, :destroy] do
          member do
            get 'preview'
          end
          
          resources :sections, only: [:index, :show, :edit, :update, :create, :destroy] do
            resources :questions, only: [:show, :edit, :new, :update, :create, :destroy] do
            end
          end
        end
      end
      
      resources :annotations, only: [:create, :destroy, :update] do ; end

      get 'template_options' => 'templates#template_options', constraints: {format: [:json]}
      get 'download_plans' => 'plans#download_plans'
    end

    namespace :super_admin do
      resources :orgs, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :themes, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :users, only: [:edit, :update]
    end
end
