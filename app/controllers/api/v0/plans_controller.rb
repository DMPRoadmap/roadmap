# frozen_string_literal: true

class Api::V0::PlansController < Api::V0::BaseController

  include Paginable

  before_action :authenticate

  ##
  # Creates a new plan based on the information passed in JSON to the API
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create
    @template = Template.live(params[:template_id])
    raise Pundit::NotAuthorizedError unless Api::V0::PlansPolicy.new(@user, @template).create?

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

    # Attach the user as the PI and Data Contact
    @plan.contributors << Contributor.new(
      name: [plan_user.firstname, plan_user.surname].join(" "),
      email: plan_user.email,
      investigation: true,
      data_curation: true
    )

    # set funder name to template's org, or original template's org
    @plan.funder_id = if @template.customization_of.nil?
                        @template.org.id
                      else
                        Template.where(
                          family_id: @template.customization_of
                        ).first.org.id
                      end
    @plan.template = @template
    @plan.title = params[:plan][:title]
    if @plan.save
      @plan.assign_creator(plan_user)
      respond_with @plan
    else
      # the plan did not save
      headers["WWW-Authenticate"] = "Token realm=\"\""
      render json: _("Bad Parameters"), status: 400
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def index
    raise Pundit::NotAuthorizedError unless Api::V0::PlansPolicy.new(@user, nil).index?

    if params[:per_page].present?
      max_pages = Rails.configuration.x.application.api_max_page_size
      params[:per_page] = max_pages if params[:per_page].to_i > max_pages
    end

    @plans = @user.org.plans.includes([{ roles: :user }, { answers: :question_options },
                                       template: [{ phases: {
                                         sections: { questions: %i[question_format themes] }
                                       } }, :org]])

    # Filter on list of users
    user_ids = extract_param_list(params, "user")
    if user_ids.present?
      @plans = @plans.where(roles: { user_id: user_ids, access: Role.bit_values(:editor) })
    end
    # filter on dates
    if params["created_after"].present? || params["created_before"].present?
      @plans = @plans.where(created_at: dates_to_range(params, "created_after", "created_before"))
    end
    if params["updated_after"].present? || params["updated_before"].present?
      @plans = @plans.where(updated_at: dates_to_range(params, "updated_after", "updated_before"))
    end
    if params["remove_tests"].present? && params["remove_tests"].downcase == "true"
      @plans = @plans.where.not(visibility: Plan.visibilities[:is_test])
    end
    # filter on funder (dmptemplate_id)
    template_ids = extract_param_list(params, "template")
    @plans = @plans.where(templates: { family_id: template_ids }) if template_ids.present?
    # filter on id(s)
    plan_ids = extract_param_list(params, "plan")
    @plans = @plans.where(id: plan_ids) if plan_ids.present?
    # apply pagination after filtering
    @args = { per_page: params[:per_page], page: params[:page] }
    @plans = refine_query(@plans)
    respond_with @plans
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable

  private

  def extract_param_list(params, attribute)
    list = params.fetch(attribute + "[]", [])
    val = params.fetch(attribute, [])
    list << val if val.present?
    list
  end

  # takes in the params hash and converts to a date-range
  def dates_to_range(hash, start, stop)
    today = Date.today
    start_date = Date.parse(hash.fetch(start, today.prev_month.to_date.to_s))
    end_date = Date.parse(hash.fetch(stop, today.to_date.to_s)) + 1.day
    start_date..end_date
  end

end
