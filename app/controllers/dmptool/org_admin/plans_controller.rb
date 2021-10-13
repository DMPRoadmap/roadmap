# frozen_string_literal: true

module Dmptool

  module OrgAdmin

    module PlansController

      # POST /org_admin/plans
      def create
        template = Template.find_by(id: plan_params[:template_attributes][:id])
        # Just piggyback off of the Template create policy since only
        # an OrgAdmin is allowed to do this
        authorize template

        template.update(
          email_subject: plan_params[:template_attributes][:email_subject],
          email_body: plan_params[:template_attributes][:email_body],
        )

        # Find or initialize the User and then create a new Plan for the template and
        # either the user's org or the org admin's org if the user is new
        user = User.find_or_initialize_by(email: plan_params[:user][:email])
        plan = Plan.create(template: template, title: "#{template.title} DMP",
                          org: user.org || current_user.org)

        if user.new_record?
          # The email address was unknown so send the user an invitation.
          # See User.deliver_invitation for handling of the email
          user = User.invite!({ email: user.email, invitation_plan_id: plan.id },
                              current_user.org)
        else
          UserMailer.new_plan_via_template(
            recipient: user, sender: current_user, plan: plan
          ).deliver_now
        end

        # Attach the user to the plan
        plan.add_user!(user.id, :creator)

        msg = _("A new DMP has been created and an email sent to '%{email}'.") % {
          email: plan_params[:user][:email]
        }
        redirect_to organisational_org_admin_templates_path, notice: msg
      end

      private

      def plan_params
        params.require(:plan).permit(user: [:email],
                                     template_attributes: %i[id email_subject email_body])
      end

    end

  end

end
