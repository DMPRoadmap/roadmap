# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  namespace :super_admin do
    resources :registries do
      post "sort_values", on: :collection
      get "download"
    end
    resources :registry_values, only: %i[new create edit update destroy]
    resources :madmp_schemas, only: %i[index new create edit update destroy]
  end

  resources :madmp_fragments, only: %i[create update destroy] do
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

  get "/codebase/run", to: "madmp_codebase#run", constraints: { format: [:json] }
  get "/codebase/anr_search", to: "madmp_codebase#anr_search", constraints: { format: [:json] }


  resources :registries, only: [] do
    get "load_values", action: :load_values, on: :collection
  end
  namespace :paginable do
    # Paginable actions for registries
    resources :registries, only: [] do
      get "index/:page", action: :index, on: :collection, as: :index
    end
    # Paginable actions for madmp schemas
    resources :madmp_schemas, only: [] do
      get "index/:page", action: :index, on: :collection, as: :index
    end
    # Paginable actions for registry values
    resources :registry_values, only: [] do
      get ":id/index/:page", action: :index, on: :collection, as: :index
    end
  end
end
# rubocop:enable Metrics/BlockLength
