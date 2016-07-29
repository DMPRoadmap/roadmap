module Api
  module V0
    class StatisticsController < Api::V0::BaseController
      before_action :authenticate

      def users_joined
        if has_auth("statistics")
          @users_count = restrict_date_range(@user.organisations.first.users).count
          respond_with @users_count
        else
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end
      end


      def using_template
        if has_auth("statistics")
          template = Dmptemplate.find(params[:id])
          if template.organisation == @user.organisations.first
            @template_count = restrict_date_range(template.projects).count
            respond_with @template_count
          else
            #no auth to view statistics for this template
          end
        else
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end
      end


      def plans_by_template
        if has_auth("templates")
          @org_projects = []
          @user.organisations.first.users.each do |user|
            @org_projects += user.projects
          end
          @org_projects = restrict_date_range(@org_projects)
          respond_with restrict_date_range(@org_projects)
        else
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end
      end


      def plans
        if has_auth("templates")
          @org_projects = []
          @user.organisations.first.users.each do |user|
            @org_projects += user.projects
          end
          @org_projects = restrict_date_range(@org_projects)
          respond_with @org_projects
        else
          render json: I18n.t("api.no_auth_for_endpoint"), status: 401
        end
      end


      private
        ##
        # takes in an array of active_reccords and restricts the range of dates
        # to those specified in the params
        #
        # @params objects [Array<ActiveReccord>] any active_reccord reccords which
        #   have the "created_at" field specified
        # @return [Array<ActiveReccord>] filtered list of objects
        def restrict_date_range( objects )
          # set start_date to either passed param, or beginning of time
          start_date = params[:start_date].blank? ? Date.new(0) : Date.strptime(params[:start_date], "%Y-%m-%d")
          # set end_date to either passed param or now
          end_date = params[:end_date].blank? ? Date.today : Date.strptime(params[:end_date], "%Y-%m-%d")

          filtered = []
          objects.each do |obj|
            if start_date <= obj.created_at.to_date && end_date >= obj.created_at.to_date
              filtered += [obj]
            end
          end
          return filtered
        end
    end
  end
end