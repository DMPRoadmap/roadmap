# frozen_string_literal: true

class StatCreatedPlansByTemplateController < ApplicationController

  def index
    check_authorized!

    data = StatCreatedPlan.monthly_range(index_filter).order(date: :desc)
    template_filter = params[:templates]

    if params[:format] == "csv"
      p params
      case template_filter
      when 'any'
        data_csvified = StatCreatedPlan.to_csv(data, details: { any_template: true })
      when 'org'
        data_csvified = StatCreatedPlan.to_csv(data, details: { org_template: true })
      end 

      send_data(data_csvified, filename: "created_plan_any_template.csv")
    else
      case template_filter
      when 'any'
        render(json: data.as_json(only: [:date, :count], methods: :any_template))
      when 'org'
        render(json: data.as_json(only: [:date, :count], methods: :org_template))
      end 
    end
  end

  private

  def index_filter
    {
      org: current_user.org,
      start_date: params[:start_date],
      end_date: params[:end_date]
    }
  end

  def check_authorized!
    unless current_user.present? &&
        current_user.can_org_admin?
      raise Pundit::NotAuthorizedError
    end
  end

end
