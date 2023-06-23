# frozen_string_literal: true

module Dmpopidor
  # Customized code for UsersController
  module UsersController
    ##
    # GET - List of all users for an organisation
    # Displays number of roles[was project_group], name, email, and last sign in
    # Added Total users count
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def admin_index
      authorize ::User

      respond_to do |format|
        format.html do
          @clicked_through = params[:click_through].present?
          @filter_admin = false
          if current_user.can_super_admin?
            @users = ::User.order('last_sign_in_at desc NULLS LAST')
                           .includes(:department, :org, :perms, :roles, :identifiers).page(1)
            @total_active = ::User.where(active: true).count
            @total_users = ::User.count
          else
            @users = current_user.org.users.order('last_sign_in_at desc NULLS LAST')
                                 .includes(:department, :org, :perms, :roles, :identifiers).page(1)
            @total_active = current_user.org.users.where(active: true).count
            @total_users = current_user.org.users.count
          end
        end

        format.csv do
          send_data ::User.to_csv(current_user.org.users.order(:surname)),
                    filename: "users-accounts-#{Date.today}.csv"
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
