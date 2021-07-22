# frozen_string_literal: true

class OrgAdmin::PlansController < ApplicationController

  # GET org_admin/plans
  def index
    # Test auth directly and throw Pundit error sincePundit
    # is unaware of namespacing
    raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?

    sql = "users.org_id = ? AND plans.feedback_requested is TRUE AND roles.active is TRUE"
    feedback_ids = Role.creator.joins(:user, :plan)
                       .where(sql, current_user.org_id).pluck(:plan_id)
    @feedback_plans = Plan.where(id: feedback_ids).reject(&:nil?)

    @super_admin = current_user.can_super_admin?
    @clicked_through = params[:click_through].present?
    @plans = @super_admin ? Plan.all.page(1) : current_user.org.plans.page(1)
  end

  # GET org_admin/plans/:id/feedback_complete
  def feedback_complete
    plan = Plan.find(params[:id])
    # Test auth directly and throw Pundit error sincePundit is
    # unaware of namespacing
    raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?
    raise Pundit::NotAuthorizedError unless plan.reviewable_by?(current_user.id)

    if plan.complete_feedback(current_user)
      # rubocop:disable Layout/LineLength
      redirect_to(org_admin_plans_path,
                  notice: _("%{plan_owner} has been notified that you have finished providing feedback") % {
                    plan_owner: plan.owner.name(false)
                  })
      # rubocop:enable Layout/LineLength
    else
      redirect_to org_admin_plans_path,
                  alert: _("Unable to notify user that you have finished providing feedback.")
    end
  end

  # GET /org_admin/download_plans
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def download_plans
    # Test auth directly and throw Pundit error sincePundit
    # is unaware of namespacing
    raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?

    org = current_user.org
    file_name = org.name.gsub(/ /, "_")
                   .gsub(/[.;,]/, "")
    header_cols = [
      _("Project title").to_s,
      _("Template").to_s,
      _("Organisation").to_s,
      _("Owner name").to_s,
      _("Owner email").to_s,
      _("Updated").to_s,
      _("Visibility").to_s
    ]

    plans = CSV.generate do |csv|
      csv << header_cols
      org.plans.includes(template: :org).order(updated_at: :desc).each do |plan|
        csv << [
          plan.title.to_s,
          plan.template.title.to_s,
          (plan.owner.org.present? ? plan.owner.org.name : "").to_s,
          plan.owner.name(false).to_s,
          plan.owner.email.to_s,
          l(plan.latest_update.to_date, format: :csv).to_s,
          Plan::VISIBILITY_MESSAGE[plan.visibility.to_sym].capitalize.to_s
        ]
      end
    end

    respond_to do |format|
      format.csv  { send_data plans, filename: "#{file_name}.csv" }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

end
