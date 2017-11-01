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
      end
    end

    resources :templates, :path => 'org/admin/templates', only: [] do
      member do
        get 'admin_index'
        get 'admin_template'
        get 'admin_new'
        get 'admin_template_history'
        get 'admin_customize'
        delete 'admin_destroy'
        post 'admin_create'
        put 'admin_update'
        put 'admin_publish'
        put 'admin_unpublish'
        put 'admin_copy'
        get 'admin_transfer_customization'
        get 'template_options', constraints: {format: [:json]}
      end
    end

    resources :phases, path: 'org/admin/templates/phases', only: [] do
      member do
        get 'admin_show'
        get 'admin_preview'
        get 'admin_add'
        put 'admin_update'
        post 'admin_create'
        delete 'admin_destroy'
      end
    end

    resources :sections, path: 'org/admin/templates/sections', only: [] do
      member do
        post 'admin_create'
        put 'admin_update'
        delete 'admin_destroy'
      end
    end

    resources :questions, path: 'org/admin/templates/questions', only: [] do
      member do
        post 'admin_create'
        put 'admin_update'
        delete 'admin_destroy'
      end
    end

    resources :annotations, path: 'org/admin/templates/annotations', only: [] do
      member do
        post 'admin_create'
        put 'admin_update'
        delete 'admin_destroy'
      end
    end

    resources :answers, only: :update

    resources :notes, only: [:create, :update, :archive] do
      member do
        patch 'archive'
      end
    end

    resources :plans do
      resources :phases do
        member do
          get 'edit'
          get 'status'
          post 'update'
        end
      end


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
      end

      collection do
        get 'possible_templates'
        get 'possible_guidance'
      end
    end

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
            get :using_template
            get :plans_by_template
            get :plans
          end
        end
      end
    end
end
