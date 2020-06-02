module Dmpopidor
  module Controllers
    module OrgAdmin
      module Users
  
        # CHANGES : Org Admin should access plan with administrator, organisation & public plan when editing a user
        def edit
          @user = User.find(params[:id])
          authorize @user
          @departments = @user.org.departments.order(:name)
          @plans = Plan.org_admin_visible(@user).page(1)
          render "org_admin/users/edit",
            locals: { user: @user,
              departments: @departments,
              plans: @plans,
              languages: @languages,
              orgs: @orgs,
              identifier_schemes: @identifier_schemes,
              default_org: @user.org }
        end

        def update
          @user = User.find(params[:id])
          authorize @user
          @departments = @user.org.departments.order(:name)
          @plans = Plan.org_admin_visible(@user).page(1)
          # Replace the 'your' word from the canned responses so that it does
          # not read 'Successfully updated your profile for John Doe'
          topic = _("profile for %{username}") % { username: @user.name(false) }
          if @user.update_attributes(user_params)
            flash.now[:notice] = success_message(@user, _("updated"))
          else
            flash.now[:alert] = failure_message(@user, _("update"))
          end
          
          render :edit
        end


        def user_plans
          @user = User.find(params[:id])
          authorize @user
          @plans = Plan.org_admin_visible(@user).page(1)
          render "org_admin/users/plans"
        end
          
      end
    end
  end
end