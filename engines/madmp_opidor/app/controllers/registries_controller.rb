# frozen_string_literal: true

# Controller that handles registries interrogation on the user's side
class RegistriesController < ApplicationController
  after_action :verify_authorized
  include DynamicFormHelper

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
