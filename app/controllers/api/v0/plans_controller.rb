# frozen_string_literal: true

class Api::V0::PlansController < Api::V0::BaseController

  before_action :authenticate

  ##
  # Creates a new plan based on the information passed in JSON to the API
  def create
    @template = Template.live(params[:template_id])
    unless Api::V0::PlansPolicy.new(@user, @template).create?
      raise Pundit::NotAuthorizedError
    end

    plan_user = User.find_by(email: params[:plan][:email])
    # ensure user exists
    if plan_user.blank?
      User.invite!({ email: params[:plan][:email] }, @user)
      plan_user = User.find_by(email: params[:plan][:email])
      plan_user.org = @user.org
      plan_user.save
    end
    # ensure user's organisation is the same as api user's
    unless plan_user.org == @user.org
      raise Pundit::NotAuthorizedError, _("user must be in your organisation")
    end

    # initialize the plan
    @plan = Plan.new
    if plan_user.surname.blank?
      @plan.principal_investigator = nil
    else
      @plan.principal_investigator = plan_user.anem(false)
    end

    @plan.data_contact = plan_user.email
    # set funder name to template's org, or original template's org
    if @template.customization_of.nil?
      @plan.funder_name = @template.org.name
    else
      @plan.funder_name = Template.where(
        family_id: @template.customization_of
      ).first.org.name
    end
    @plan.template = @template
    @plan.title = params[:plan][:title]
    if @plan.save
      @plan.assign_creator(plan_user)
      respond_with @plan
    else
      # the plan did not save
      self.headers["WWW-Authenticate"] = "Token realm=\"\""
      render json: _("Bad Parameters"), status: 400
    end
  end

  def index
    unless Api::V0::PlansPolicy.new(@user, nil).index?
      raise Pundit::NotAuthorizedError
    end
    if params[:per_page].present? && params[:per_page].to_i > Rails.configuration.branding[:application][:api_max_page_size]
      params[:per_page] = Rails.configuration.branding[:application][:api_max_page_size]
    end
    @plans = paginate @user.org.plans.includes( [ {roles: :user}, {answers: :question_options} ,
      template: [ { phases: { sections: { questions: [:question_format, :themes ] } } }, :org]
      ])
    
    # Filter on list of users
    user_ids = extract_param_list(params, "user")
    @plans = @plans.where(roles: {user_id: user_ids}) if user_ids.present?
    # filter on dates
    if params["created_after"].present? || params["created_before"].present?
      @plans = @plans.where(created_at: dates_to_range(params,"created_after","created_before"))
    end
    if params["updated_after"].present? || params["updated_before"].present?
      @plans = @plans.where(updated_at: dates_to_range(params,"updated_after","updated_before"))
    end
    # filter on funder (dmptemplate_id)
    template_ids = extract_param_list(params, "template")
    @plans = @plans.where(templates: {family_id: template_ids}) if template_ids.present?
    # filter on id(s)
    plan_ids = extract_param_list(params, "plan")
    @plans = @plans.where(id: plan_ids ) if plan_ids.present?
    respond_with @plans
  end

  private

  def extract_param_list(params, attribute)
    list = params.fetch(attribute+"[]", [])
    val = params.fetch(attribute, [])
    list << val if val.present?
    list
  end

  # takes in the params hash and converts to a date-range
  def dates_to_range(hash,start,stop)
    today = Date.today
    start_date = Date.parse(hash.fetch(start, today.prev_month.to_date.to_s))
    end_date = Date.parse(hash.fetch(stop, today.to_date.to_s)) + 1.day
    start_date..end_date
  end

end
