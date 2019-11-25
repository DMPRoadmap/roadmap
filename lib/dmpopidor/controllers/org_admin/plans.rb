module Dmpopidor
  module Controllers
    module OrgAdmin
      module Plans

        # GET org_admin/plans
        # In the Org Admin page, Private and Test plans won't be displayed
        def index
          unless current_user.present? && current_user.can_org_admin?
            raise Pundit::NotAuthorizedError
          end

          feedback_ids = Role.creator.joins(:user,:plan)
            .where('users.org_id = ? AND plans.feedback_requested is TRUE AND roles.active is TRUE',
              current_user.org_id).pluck(:plan_id)
          @feedback_plans = Plan.where(id: feedback_ids).reject{|p| p.nil?}
          @plans = current_user.org.plans.where.not(visibility: [Plan.visibilities[:privately_visible], Plan.visibilities[:is_test]]).page(1)
        end

        # CHANGES
        # Removed Private plans from download
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
            org.plans
                .where.not(visibility: Plan.visibilities[:privately_visible])
                .includes(template: :org).order(updated_at: :desc).each do |plan|
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
    end
  end
end