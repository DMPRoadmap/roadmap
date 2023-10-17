# frozen_string_literal: true

# Controller that handles registries interrogation on the user's side
class RegistriesController < ApplicationController
  after_action :verify_authorized
  include DynamicFormHelper

  def show
    registry = Registry.find(params[:id])
    registry_values = registry.registry_values

    skip_authorization
    render json: registry_values.pluck(:data)
  end

  def by_name
    registry = Registry.find_by(name: params[:name])
    registry_values = params[:page] ? registry.registry_values.page(params[:page]) : registry.registry_values

    skip_authorization
    render json: registry_values.pluck(:data)
  end

  # rubocop:disable Metrics/AbcSize
  def load_values
    registry = Registry.find(params[:id])
    plan = Plan.find(params[:plan_id])
    locale = plan.template.locale
    search_term = params[:term] || ''
    values_list = registry.registry_values
    formatted_list = values_list.select { |v| v.to_s(locale:).downcase.include?(search_term.downcase) }
                                .map    { |v| { 'id' => select_value(v, locale), 'text' => v.to_s(locale:) } }
    authorize plan
    render json: {
      'results' => formatted_list
    }
  end
  # rubocop:enable Metrics/AbcSize
end
