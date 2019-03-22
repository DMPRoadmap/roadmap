module Dmpopidor
  module Controllers
    module Roles
      # Changed notification message
      def update
        @role = Role.find(params[:id])
        authorize @role
    
        if @role.update_attributes(access: role_params[:access])
          deliver_if(recipients: @role.user, key: "users.added_as_coowner") do |r|
            UserMailer.permissions_change_notification(@role, current_user).deliver_now
          end
          # rubocop:disable LineLength
          render json: {
            code: 1,
            msg: d_('dmpopidor', "Successfully changed the permissions for %{user_email}. They have been notified via email.") % { :user_email => @role.user.email }
          }
          # rubocop:enable LineLength
        else
          render json: { code: 0, msg: flash[:alert] }
        end
      end
    end
  end
end