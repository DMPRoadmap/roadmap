module Dmpopidor
  module Controllers
    module Roles
      
      # CHANGES : Invited user should be linked to default org
      def create
        registered = true
        @role = Role.new(role_params)
        authorize @role
    
        plan = Plan.find(role_params[:plan_id])
    
        message = ""
        if params[:user].present? && plan.present?
          if @role.plan.owner.present? && @role.plan.owner.email == params[:user]
            # rubocop:disable Metrics/LineLength
            flash[:notice] = _("Cannot share plan with %{email} since that email matches with the owner of the plan.") % {
                email: params[:user]
            }
            # rubocop:enable Metrics/LineLength
          else
            user = User.where_case_insensitive("email", params[:user]).first
            if Role.find_by(plan: @role.plan, user: user) # role already exists
                flash[:notice] = _("Plan is already shared with %{email}.") % {
                email: params[:user]
                }
            else
              if user.nil?
                registered = false
                User.invite!({email:     params[:user],
                            firstname:  _("First Name"),
                            surname:    _("Surname"),
                            org:        Org.find_by(is_other: true),
                            other_organisation: "PLEASE CHOOSE AN ORGANISATION IN YOUR PROFILE" },
                            current_user )
                message = _("Invitation to %{email} issued successfully.") % {
                    email: params[:user]
                }
                user = User.where_case_insensitive("email", params[:user]).first
              end
                message += _("Plan shared with %{email}.") % {
                email: user.email
                }
                @role.user = user
              if @role.save
                if registered
                    deliver_if(recipients: user, key: "users.added_as_coowner") do |r|
                    UserMailer.sharing_notification(@role, r, inviter: current_user)
                                .deliver_now
                end
              end
                flash[:notice] = message
              else
                # rubocop:disable Metrics/LineLength
                flash[:alert] = _("You must provide a valid email address and select a permission level.")
                # rubocop:enable Metrics/LineLength
              end
            end
          end
        else
          flash[:alert] = _("Please enter an email address")
        end
        redirect_to controller: "plans", action: "share", id: @role.plan.id
      end
    end
  end
end