Rails.application.routes.draw do

  devise_for :users, controllers: {
        registrations: "registrations", 
        confirmations: 'confirmations', 
        passwords: 'passwords', 
        sessions: 'sessions', 
        omniauth_callbacks: 'users/omniauth_callbacks'} do
        
    get "/users/sign_out", :to => "devise/sessions#destroy"
  end
  
  # WAYFless access point - use query param idp
  get 'auth/shibboleth' => 'users/omniauth_shibboleth_request#redirect', :as => 'user_omniauth_shibboleth'
  get 'auth/shibboleth/assoc' => 'users/omniauth_shibboleth_request#associate', :as => 'user_shibboleth_assoc'

  #post '/auth/:provider/callback' => 'sessions#oauth_create'
  
  # fix for activeadmin signout bug
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end

  delete '/users/identifiers/:id', to: 'user_identifiers#destroy', as: 'destroy_user_identifier'
  
  ActiveAdmin.routes(self)

  #organisation admin area
  #match "org/admin/users" => 'organisation_users#admin_index', :as => "org/admin/users"
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
  root :to => 'home#index'
  get '/:locale' => 'home#index', :as => 'locale_root'

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    get "about_us" => 'static_pages#about_us'
    get "help" => 'static_pages#help'
    get "roadmap" => 'static_pages#roadmap'
    get "terms" => 'static_pages#termsuse'
    get "public_plans" => 'static_pages#public_plans'
    get "public_export/:id" => 'static_pages#public_export', as: 'public_export'
    
    get "existing_users" => 'existing_users#index'
  
    #post 'contact_form' => 'contacts', as: 'localized_contact_creation'
    #get 'contact_form' => 'contacts#new', as: 'localized_contact_form'
    
    resources :organisations, :path => 'org/admin', only: [] do
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

    resources :dmptemplates, :path => 'org/admin/templates', only: [] do
      member do
        get 'admin_index'
        get 'admin_template'
        get 'admin_new'
        get 'admin_addphase'
        get 'admin_phase'
        get 'admin_previewphase'
        get 'admin_cloneversion'
        delete 'admin_destroy'
        delete 'admin_destroyversion'
        delete 'admin_destroyphase'
        delete 'admin_destroysection'
        delete 'admin_destroyquestion'
        delete 'admin_destroysuggestedanswer'
        post 'admin_create'
        post 'admin_createphase'
        post 'admin_createsection'
        post 'admin_createquestion'
        post 'admin_createsuggestedanswer'
        put 'admin_update'
        put 'admin_updatephase'
        put 'admin_updateversion'
        put 'admin_updatesection'
        put 'admin_updatequestion'
        put 'admin_updatesuggestedanswer'
      end
    end

    resources :answers, only: :create

    resources :comments, only: [:create, :update] do
      member do
        put 'archive'
      end
    end

    resources :projects do
      resources :plans , only: [:edit, :update] do
        member do
          get 'status'
          get 'locked'
          get 'answer'
          #get 'edit'
          post 'delete_recent_locks'
          post 'lock_section', constraints: {format: [:html, :json]}
          post 'unlock_section', constraints: {format: [:html, :json]}
          post 'unlock_all_sections'
          get 'export'
          get 'warning'
          get 'section_answers'
        end
      end

      member do
        get 'share'
        get 'export'
        post 'invite'
      end
      collection do
        get 'possible_templates'
        get 'possible_guidance'
      end
    end

    resources :project_groups, only: [:create, :update, :destroy]

    namespace :settings do
      resource :projects, only: [:show, :update]
      resources :plans, only: [:show, :update]
    end

    resources :token_permission_types, only: [:index]

    namespace :api, defaults: {format: :json} do
      namespace :v0 do
        resources :guidance_groups, only: [:index, :show]
        resources :plans, only: :create, controller: "projects", path: "plans"
        resources :templates, only: :index, controller: "dmptemplates", path: "templates"
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

    # The priority is based upon order of creation:
    # first created -> highest priority.

    # Sample of regular route:
    #   match 'products/:id' => 'catalog#view'
    # Keep in mind you can assign values other than :controller and :action

    # Sample of named route:
    #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
    # This route can be invoked with purchase_url(:id => product.id)

    # Sample resource route (maps HTTP verbs to controller actions automatically):
    #   resources :products

    # Sample resource route with options:
    #   resources :products do
    #     member do
    #       get 'short'
    #       post 'toggle'
    #     end
    #
    #     collection do
    #       get 'sold'
    #     end
    #   end

    # Sample resource route with sub-resources:
    #   resources :products do
    #     resources :comments, :sales
    #     resource :seller
    #   end

    # Sample resource route with more complex sub-resources
    #   resources :products do
    #     resources :comments
    #     resources :sales do
    #       get 'recent', :on => :collection
    #     end
    #   end

    # Sample resource route within a namespace:
    #   namespace :admin do
    #     # Directs /admin/products/* to Admin::ProductsController
    #     # (app/controllers/admin/products_controller.rb)
    #     resources :products
    #   end


    # See how all your routes lay out with "rake routes"

    # This is a legacy wild controller route that's not recommended for RESTful applications.
    # Note: This route will make all actions in every controller accessible via GET requests.
    # match ':controller(/:action(/:id))(.:format)'
  end
end
