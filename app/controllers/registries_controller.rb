# frozen_string_literal: true

class RegistriesController < ApplicationController

  after_action :verify_authorized
  include DynamicFormHelper

  def load_values
    registry = Registry.find(params[:id])
    plan = Plan.find(params[:plan_id])
    locale = plan.template.locale
    search_term = params[:term] || ""
    values_list = registry.registry_values
    # rubocop:disable Layout/LineLength
    formatted_list = values_list.select { |v| v.to_s(locale: locale).downcase.include?(search_term.downcase) }
                                .map    { |v| { "id" => select_value(v, locale), "text" => v.to_s(locale: locale) } }
    # rubocop:enable Layout/LineLength
    authorize plan
    render json: {
      "results" => formatted_list
    }
  end

end
