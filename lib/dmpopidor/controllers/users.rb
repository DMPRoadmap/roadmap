module Dmpopidor
  module Controllers
    module Users
      
      ##
      # GET - List of all users for an organisation
      # Displays number of roles[was project_group], name, email, and last sign in
      # Added Total users count
      def admin_index
        authorize User

        respond_to do |format|
          format.html do
            if current_user.can_super_admin?
              @users = User.order("last_sign_in_at desc NULLS LAST").includes(:roles).page(1)
              @total_users = User.count
            else
              @users = current_user.org.users.order("last_sign_in_at desc NULLS LAST").includes(:roles).page(1)
              @total_users = current_user.org.users.count
            end
          end
      
          format.csv do
            send_data User.to_csv(current_user.org.users.order(:surname)),
            filename: "users-accounts-#{Date.today}.csv"
          end
        end
      end
    end
  end
end