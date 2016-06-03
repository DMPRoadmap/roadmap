DMPonline4::Application.routes.draw do

	devise_for :users, :controllers => {:registrations => "registrations", :confirmations => 'confirmations', :passwords => 'passwords', :sessions => 'sessions', :omniauth_callbacks => 'users/omniauth_callbacks'} do
		get "/users/sign_out", :to => "devise/sessions#destroy"
	end 
	resources :contacts, :controllers => {:contacts => 'contacts'}
	
	# WAYFless access point - use query param idp
	get 'auth/shibboleth' => 'users/omniauth_shibboleth_request#redirect', :as => 'user_omniauth_shibboleth'
	get 'auth/shibboleth/assoc' => 'users/omniauth_shibboleth_request#associate', :as => 'user_shibboleth_assoc'

	
	ActiveAdmin.routes(self)
	
	# You can have the root of your site routed with "root"
	# just remember to delete public/index.html.
	root :to => 'home#index'

	get "about_us" => 'static_pages#about_us', :as => "about_us"
	get "help" => 'static_pages#help', :as => "help"
	get "roadmap" => 'static_pages#roadmap', :as => "roadmap"
	get "terms" => 'static_pages#termsuse', :as => "terms"

	#organisation admin area
	get "org/admin/users" => 'organisation_users#admin_index', :as => "org/admin/users"
 
 	resources :organisations, :path => 'org/admin' do
		member do
			get 'children'
			get 'templates'
			get 'admin_show'
			get 'admin_edit'
			put 'admin_update', :as => 'admin_update'
		end
	end
 
 	resources :guidances, :path => 'org/admin/guidance' do
		member do
			get 'admin_show'
			get 'admin_index'
			get 'admin_edit'
			get 'admin_new'
			delete 'admin_destroy' 
			post 'admin_create'
			put 'admin_update', :as => 'admin_update'
			get 'update_phases', :as => 'update_phases'
			get 'update_versions', :as => 'update_versions'
			get 'update_sections', :as => 'update_sections'
			get 'update_questions', :as => 'update_questions'
		end
	end
 
 	resources :guidance_groups, :path => 'org/admin/guidancegroup' do
 		member do
 			get 'admin_show'
 			get 'admin_new'
 			get 'admin_edit'
 			delete 'admin_destroy' 
			post 'admin_create'
            put 'admin_update', :as=> 'admin_update'
            
		end
	end
 
 	resource :organisation 
 
	resources :dmptemplates, :path => 'org/admin/templates' do
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
            post 'admin_createguidance'
			put 'admin_update', :as => 'admin_update'
			put 'admin_updatephase', :as => 'admin_updatephase'
			put 'admin_updateversion', :as => 'admin_updateversion'
			put 'admin_updatesection', :as => 'admin_updatesection'
			put 'admin_updatequestion', :as => 'admin_updatequestion'
			put 'admin_updatesuggestedanswer', :as => 'admin_updatesuggestedanswer'
		end
	end
   
	resources :phases
	resources :versions
	resources :sections
	resources :questions
	resources :question_themes


	resources :themes

	resources :answers
	resources :plan_sections
	resources :comments do
		member do
			put 'archive'
		end
	end

	
	
	resources :projects do
		resources :plans do
			member do
				get 'status'
				get 'locked'
				get 'answer'
				get 'edit'
				post 'delete_recent_locks'
				post 'lock_section'
				post 'unlock_section'
				post 'unlock_all_sections'
				get 'export'
				get 'warning'
				get 'section_answers'
			end
		end
	end
	
	resources :projects do
		member do
			get 'share'
			get 'export'
			post 'invite'
			post 'create'
		end
		
		collection do
			get 'possible_templates'
			get 'possible_guidance'
		end
	end
	
	 
	resources :project_partners
	resources :project_groups

	resources :users
	resources :user_statuses
	resources :user_types

	resources :user_role_types
	resources :user_org_roles


	resources :organisation_types

	resources :file_types
	resources :file_uploads

	namespace :settings do
		resource :projects
		resources :plans
	end

end
