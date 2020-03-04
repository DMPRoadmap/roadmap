module Dmpopidor
  module Controllers
    module OrgAdmin
      module Plans
  
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
          
      end
    end
  end
end