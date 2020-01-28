# frozen_string_literal: true

class UsageController < ApplicationController

  after_action :verify_authorized

  # GET /usage
  def index
    authorize :usage

    args = default_query_args
    user_data(args: args, as_json: true)
    plan_data(args: args, as_json: true)
    total_plans(args: min_max_dates(args: args))
    total_users(args: min_max_dates(args: args))
  end

  # POST /usage_plans_by_template
  def plans_by_template
    # This action is triggered when a user changes the timeframe for the
    # plans by template chart
    authorize :usage

    args = default_query_args
    if usage_params["template_plans_range"].present?
      args[:start_date] = usage_params["template_plans_range"]
    end
    plan_data(args: args, as_json: true)
  end

  # GET
  def global_statistics
    # This action is triggered when a user clicks on the 'download csv' button
    # for global usage
    authorize :usage

    data = Org::TotalCountStatService.call
    data_csvified = Csvable.from_array_of_hashes(data)

    send_data(data_csvified, filename: "totals.csv")
  end

  # POST /usage_filter
  # rubocop:disable Metrics/MethodLength
  def filter
    # This action is triggered when a user specifies a date range
    authorize :usage

    args = args_from_params
    plan_data(args: args)
    user_data(args: args)
    total_plans(args: min_max_dates(args: args))
    total_users(args: min_max_dates(args: args))

    @topic = usage_params[:topic]
    case @topic
    when "plans"
      @total = @total_org_plans
      @ranged = @plans_per_month.sum(:count)
    else
      @total = @total_org_users
      @ranged = @users_per_month.sum(:count)
    end
  end
  # rubocop:enable Metrics/MethodLength

  # GET /usage_yearly_users
  def yearly_users
    # This action is triggered when a user clicks on the 'download csv' button
    # for the annual users chart
    authorize :usage

    user_data(args: default_query_args)
    send_data(CSV.generate do |csv|
      csv << [_("Month"), _("No. Users joined")]
      total = 0
      @users_per_month.each do |data|
        csv << [data.date.strftime("%b-%y"), data.count]
        total += data.count
      end
      csv << [_("Total"), total]
    end, filename: "users_joined.csv")
  end

  # GET /usage_yearly_plans
  def yearly_plans
    # This action is triggered when a user clicks on the 'download csv' button
    # for the annual plans chart
    authorize :usage

    plan_data(args: default_query_args)
    send_data(CSV.generate do |csv|
      csv << [_("Month"), _("No. Completed Plans")]
      total = 0
      @plans_per_month.each do |data|
        csv << [data.date.strftime("%b-%y"), data.count]
        total += data.count
      end
      csv << [_("Total"), total]
    end, filename: "completed_plans.csv")
  end

  # GET /usage_all_plans_by_template
  def all_plans_by_template
    # This action is triggered when a user clicks on the 'download csv' button
    # for the plans by template chart
    authorize :usage

    args = default_query_args
    args[:start_date] = first_plan_date

    plan_data(args: args, sort: :desc)
    data_csvified = StatCreatedPlan.to_csv(@plans_per_month, details: { by_template: true })
    send_data(data_csvified, filename: "created_plan_by_template.csv")
  end

  private

  def usage_params
    params.require(:usage).permit(:template_plans_range, :org_id, :start_date,
                                  :end_date, :topic)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def args_from_params
    org = current_user.org
    if current_user.can_super_admin? && usage_params[:org_id].present?
      org = Org.find_by(id: usage_params[:org_id])
    end

    start_date = usage_params[:start_date] if usage_params[:start_date].present?
    end_date = usage_params[:end_date] if usage_params[:end_date].present?

    {
      org: org,
      start_date: start_date.present? ? start_date : first_plan_date.strftime("%Y-%m-%d"),
      end_date: end_date.present? ? end_date : Date.today.strftime("%Y-%m-%d")
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  def default_query_args
    # Stats are generated at the beginning of each month, so our reference
    # point would be the end of the prior month. For example if it is December
    # 15th 2019 then the most recent stats would be for the month of November 2019.
    # That means we want our date range to be 11/30/2018 to 11/30/2019
    {
      org: current_user.org,
      start_date: Date.today.months_ago(12).end_of_month.strftime("%Y-%m-%d"),
      end_date: Date.today.last_month.end_of_month.strftime("%Y-%m-%d")
    }
  end

  def min_max_dates(args:)
    args[:start_date] = first_plan_date.strftime("%Y-%m-%d")
    args[:end_date] = Date.today.strftime("%Y-%m-%d")
    args
  end

  def user_data(args:, as_json: false, sort: :asc)
    @users_per_month = StatJoinedUser.monthly_range(args)
                                     .order(date: sort)
    @users_per_month = @users_per_month.map { |rec| rec.to_json } if as_json
  end

  def plan_data(args:, as_json: false, sort: :asc)
    @plans_per_month = StatCreatedPlan.monthly_range(args)
                                      .where.not(details: "{\"by_template\":[]}")
                                      .order(date: sort)
    @plans_per_month = @plans_per_month.map { |rec| rec.to_json } if as_json
  end

  def total_plans(args:)
    @total_org_plans = StatCreatedPlan.monthly_range(args).sum(:count)
  end

  def total_users(args:)
    @total_org_users = StatJoinedUser.monthly_range(args).sum(:count)
  end

  def first_plan_date
    StatCreatedPlan.all.order(:date).limit(1).pluck(:date).first
  end

end
