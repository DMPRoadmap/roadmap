# frozen_string_literal: true

class StatCreatedPlansByTemplateController < ApplicationController

  def index
    check_authorized!

    data = StatCreatedPlan.monthly_range(index_filter).order(date: :desc)

    if params[:format] == "csv"
      data_csvified = StatCreatedPlan.to_csv(data, details: { by_template: true })
      send_data(data_csvified, filename: "created_plan_by_template.csv")
    else
      render(json: data.as_json(only: [:date, :count], methods: :by_template))
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
