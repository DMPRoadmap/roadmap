# frozen_string_literal: true

class Api::V0::StatisticsController < Api::V0::BaseController

  before_action :authenticate

  # GET /api/v0/statistics/users_joined?start_date=&end_date=&org_id=
  #
  # Returns the number of users joined for the user's org.
  # If start_date is passed, only counts those with created_at is >= than start_date
  # If end_date is passed, only counts those with created_at is <= than end_date are
  # If org_id is passed and user has super_admin privileges that counter is performed
  # against org_id param instead of user's org
  def users_joined
    unless Api::V0::StatisticsPolicy.new(@user, :statistics).users_joined?
      raise Pundit::NotAuthorizedError
    end

    if @user.can_super_admin? && params[:org_id].present?
      scoped = User.unscoped.where(org_id: params[:org_id])
    else
      scoped = User.unscoped.where(org_id: @user.org_id)
    end

    if params[:range_dates].present?
      r = {}
      params[:range_dates].each_pair do |k, v|
        r[k] = scoped.where(created_at: dates_to_range(v)).count
      end

      # Reverse hash r, so dates in ascending order
      r = Hash[r.to_a.reverse]

      respond_to do |format|
        format.json { render(json: r.to_json) }
        format.csv {
          send_data(CSV.generate do |csv|
            csv << [_("Month"), _("No. Users joined")]
            total = 0
            r.each_pair { |k, v| csv << [k, v]; total += v }
            csv << [_("Total"), total]
          end, filename: "#{_('users_joined')}.csv") }
      end
    else
      if params["start_date"].present? || params["end_date"].present?
        scoped = scoped.where(created_at: dates_to_range(params))
      end
      @users_count = scoped.count
      respond_with @users_count
    end
  end
  # GET
  # Returns the number of completed plans within the user's org for the data
  # start_date and end_date specified
  def completed_plans
    unless Api::V0::StatisticsPolicy.new(@user, :statistics).completed_plans?
      raise Pundit::NotAuthorizedError
    end

    if @user.can_super_admin? && params[:org_id].present?
      scoped = Org.find(params[:org_id]).plans.where(complete: true)
    else
      scoped = @user.org.plans.where(complete: true)
    end

    if params[:range_dates].present?
      r = {}
      params[:range_dates].each_pair do |k, v|
        r[k] = scoped.where(created_at: dates_to_range(v)).count
      end

      # Reverse hash r, so dates in ascending order
      r = Hash[r.to_a.reverse]

      respond_to do |format|
        format.json { render(json: r.to_json) }
        format.csv {
          send_data(CSV.generate do |csv|
            csv << [_("Month"), _("No. Completed Plans")]
            total = 0
            r.each_pair { |k, v| csv << [k, v]; total += v }
            csv << [_("Total"), total]
          end, filename: "#{_('completed_plans')}.csv") }
      end
    else
      if params["start_date"].present? || params["end_date"].present?
        scoped = scoped.where(created_at: dates_to_range(params))
      end
      render(json: { completed_plans: scoped.count })
    end
  end

  # /api/v0/statistics/created_plans
  # Returns the number of created plans within the user's org for the data
  # start_date and end_date specified
  def created_plans
    unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans?
      raise Pundit::NotAuthorizedError
    end

    if @user.can_super_admin? && params[:org_id].present?
      scoped = Org.find(params[:org_id]).plans
    else
      scoped = @user.org.plans
    end

    if params[:range_dates].present?
      r = {}
      params[:range_dates].each_pair do |k, v|
        r[k] = scoped.where(created_at: dates_to_range(v)).count
      end

      # Reverse hash r, so dates in ascending order
      r = Hash[r.to_a.reverse]

      respond_to do |format|
        format.json { render(json: r.to_json) }
        format.csv {
          send_data(CSV.generate do |csv|
            csv << [_("Month"), _("No. Plans")]
            total = 0
            r.each_pair { |k, v| csv << [k, v]; total += v }
            csv << [_("Total"), total]
          end, filename: "#{_('plans')}.csv") }
      end
    else
      if params["start_date"].present? || params["end_date"].present?
        scoped = scoped.where(created_at: dates_to_range(params))
      end
      render(json: { completed_plans: scoped.count })
    end
  end

  ##
  # Displays the number of DMPs using templates owned/create by the caller's Org
  # between the optional specified dates
  def using_template
    org_templates = @user.org.templates.where(customization_of: nil)
    unless Api::V0::StatisticsPolicy.new(@user, org_templates.first).using_template?
      raise Pundit::NotAuthorizedError
    end
    @templates = {}
    org_templates.each do |template|
      if @templates[template.title].blank?
        @templates[template.title]          = {}
        @templates[template.title][:title]  = template.title
        @templates[template.title][:id]     = template.family_id
        @templates[template.title][:uses]   = 0
      end
      scoped = template.plans
      if params["start_date"].present? || params["end_date"].present?
        scoped = scoped.where(created_at: dates_to_range(params))
      end
      @templates[template.title][:uses] += scoped.length
    end
    respond_with @templates
  end

  ##
  # GET
  # Renders a list of templates with their titles, ids, and uses between the optional
  # specified dates the uses are restricted to DMPs created by users of the same
  # organisation as the user who ititiated the call.
  def plans_by_template
    unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans_by_template?
      raise Pundit::NotAuthorizedError
    end
    @templates = {}
    scoped = @user.org.plans
    if params["start_date"].present? || params["end_date"].present?
      scoped = scoped.where(created_at: dates_to_range(params))
    end
    scoped.each do |plan|
      # if hash exists
      if @templates[plan.template.title].blank?
        @templates[plan.template.title] = {}
        @templates[plan.template.title][:title] = plan.template.title
        @templates[plan.template.title][:id] = plan.template.family_id
        @templates[plan.template.title][:uses] = 1
      else
        @templates[plan.template.title][:uses] += 1
      end
    end
    respond_with @templates
  end

  # GET
  #
  # Renders a list of DMPs metadata, provided the DMPs were created between the
  # optional specified dates DMPs must be owned by a user who's organisation is the
  # same as the user who generates the call.
  def plans
    unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans?
      raise Pundit::NotAuthorizedError
    end
    @org_plans = @user.org.plans
    if params["start_date"].present? || params["end_date"].present?
      @org_plans = @org_plans.where(created_at: dates_to_range(params))
    end
    respond_with @org_plans
  end


  private

  # Convert start/end dates in hash to a range of Dates
  def dates_to_range(hash)
    today = Date.today
    start_date = Date.parse(hash.fetch("start_date", today.prev_month.to_date.to_s))
    end_date = Date.parse(hash.fetch("end_date", today.to_date.to_s)) + 1.day
    start_date..end_date
  end

end
