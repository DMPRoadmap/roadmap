# frozen_string_literal: true

class OrgAdmin::PlansController < ApplicationController

  # GET org_admin/plans
  def index
    # Test auth directly and throw Pundit error sincePundit
    # is unaware of namespacing
    unless current_user.present? && current_user.can_org_admin?
      raise Pundit::NotAuthorizedError
    end

    feedback_ids = Role.creator.joins(:user,:plan)
      .where('users.org_id = ? AND plans.feedback_requested is TRUE AND roles.active is TRUE',
              current_user.org_id).pluck(:plan_id)
    @feedback_plans = Plan.where(id: feedback_ids).reject{|p| p.nil?}
    @super_admin = current_user.can_super_admin?
    @filter = params[:month]

    if current_user.can_super_admin? && !@filter.present?
      @plans = Plan.all.page(1)
    elsif @filter.present?
      # Convert an incoming month from the usage dashboard into a date range query
      # the month is appended to the query string when a user clicks on a bar in
      # the plans created chart
      start_date = Date.parse("#{@filter}-01")

      # Also ignore tests here since the usage dashboard ignores them and showing
      # them here may be confusing to the user
      @plans = current_user.org.plans
                           .where.not(visibility: Plan.visibilities[:is_test])
                           .where("plans.created_at BETWEEN ? AND ?",
                                  start_date.to_s, start_date.end_of_month.to_s)
                           .page(1)
    else
      @plans = current_user.org.plans.page(1)
    end
  end

  # GET org_admin/plans/:id/feedback_complete
  def feedback_complete
    plan = Plan.find(params[:id])
    # Test auth directly and throw Pundit error sincePundit is
    # unaware of namespacing
    unless current_user.present? && current_user.can_org_admin?
      raise Pundit::NotAuthorizedError
    end
    unless plan.reviewable_by?(current_user.id)
      raise Pundit::NotAuthorizedError
    end

    if plan.complete_feedback(current_user)
      # rubocop:disable Metrics/LineLength
      redirect_to(org_admin_plans_path,
        notice: _("%{plan_owner} has been notified that you have finished providing feedback") % {
          plan_owner: plan.owner.name(false)
        }
      )
      # rubocop:enable Metrics/LineLength
    else
      redirect_to org_admin_plans_path,
        alert: _("Unable to notify user that you have finished providing feedback.")
    end
  end

  # GET /org_admin/download_plans
  def download_plans
    # Test auth directly and throw Pundit error sincePundit
    # is unaware of namespacing
    unless current_user.present? && current_user.can_org_admin?
      raise Pundit::NotAuthorizedError
    end

    org = current_user.org
    file_name = org.name.gsub(/ /, "_")
                        .gsub(/[\.;,]/, "")
    header_cols = [
      "#{_('Project title')}",
      "#{_('Template')}",
      "#{_('Organisation')}",
      "#{_('Owner name')}",
      "#{_('Owner email')}",
      "#{_('Updated')}",
      "#{_('Visibility')}"
    ]

    plans = CSV.generate do |csv|
      csv << header_cols
      org.plans.includes(template: :org).order(updated_at: :desc).each do |plan|
        owner = plan.owner
        csv << [
          "#{plan.title}",
          "#{plan.template.title}",
          "#{plan.owner.org.present? ? plan.owner.org.name : ''}",
          "#{plan.owner.name(false)}",
          "#{plan.owner.email}",
          "#{l(plan.latest_update.to_date, format: :csv)}",
          "#{Plan::VISIBILITY_MESSAGE[plan.visibility.to_sym].capitalize}"
        ]
      end
    end

    respond_to do |format|
      format.csv  { send_data plans,  filename: "#{file_name}.csv" }
    end
  end

end
