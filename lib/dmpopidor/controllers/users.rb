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

      ##
      # CHANGES : USERS without perms should receive a perm when granted
      # POST - updates the permissions for a user
      # redirects to the admin_index action
      # should add validation that the perms given are current perms of the current_user
      def admin_update_permissions
        @user = User.find(params[:id])
        authorize @user
        perms_ids = params[:perm_ids].blank? ? [] : params[:perm_ids].map(&:to_i)
        perms = Perm.where(id: perms_ids)
        privileges_changed = false
        if @user.perms.empty? 
          @user.perms << perms
          privileges_changed = true
        else
          current_user.perms.each do |perm|
            if @user.perms.include? perm
              if ! perms.include? perm
                @user.perms.delete(perm)
                if perm.id == Perm.use_api.id
                  @user.remove_token!
                end
                privileges_changed = true
              end
            else
              if perms.include? perm
                @user.perms << perm
                if perm.id == Perm.use_api.id
                  @user.keep_or_generate_token!
                  privileges_changed = true
                end
              end
            end
          end
        end 

        if @user.save
          if privileges_changed
            deliver_if(recipients: @user, key: "users.admin_privileges") do |r|
              UserMailer.admin_privileges(r).deliver_now
            end
          end
          render(json: {
            code: 1,
            msg: success_message(perms.first_or_initialize, _("saved")),
            current_privileges: render_to_string(partial: "users/current_privileges",
                                                locals: { user: @user }, formats: [:html])
            })
        else
          render(json: { code: 0, msg: failure_message(@user, _("updated")) })
        end
      end
    end
  end
end