module Api
  module V0
    class StatisticsController < Api::V0::BaseController
      before_action :authenticate

      ##
      # GET
      # @return a count of users who joined DMPonline between the optional specified dates
      # users are scoped to the organisation of the user initiating the call
      def users_joined
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).users_joined?
        users = restrict_date_range(@user.org.users)
        confirmed_users = []
        users.each do |user|
          unless user.confirmed_at.blank?
            confirmed_users += [user]
          end
        end
        @users_count = confirmed_users.count
        respond_with @users_count
      end


      ##
      # GET
      # @return the number of DMPs using the specified template between the optional specified dates
      # ensures that the template is owned/created by the caller's organisation
      def using_template
        template = Template.find(params[:id])
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, template).using_template?
        @template_count = restrict_date_range(template.plans).count
        respond_with @template_count
      end

      ##
      # GET
      # @return a list of templates with their titles, ids, and uses between the optional specified dates
      # the uses are restricted to DMPs created by users of the same organisation
      # as the user who ititiated the call
      def plans_by_template
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans_by_template?
        @org_projects = []
        @user.org.users.each do |user|
          user.plans.each do |plan|
            unless @org_projects.include? plan
              @org_projects += [plan]
            end
          end
        end
        @org_projects = restrict_date_range(@org_projects)
        respond_with @org_projects
      end

      ##
      # GET
      # @return a list of DMPs metadata, provided the DMPs were created between the optional specified dates
      # DMPs must be owned by a user who's organisation is the same as the user
      # who generates the call
      def plans
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans?
        @org_plans = []
        @user.org.users.each do |user|
          user.plans.each do |plan|
            unless @org_plans.include? plan
              @org_plans += [plan]
            end
          end
        end
        @org_plans = restrict_date_range(@org_plans)
        respond_with @org_plans
      end


      private
        ##
        # takes in an array of active_reccords and restricts the range of dates
        # to those specified in the params
        #
        # @param objects [Array<ActiveReccord>] any active_reccord reccords which
        #   have the "created_at" field specified
        # @return [Array<ActiveReccord>] filtered list of objects
        def restrict_date_range( objects )
          # set start_date to either passed param, or beginning of time
          start_date = params[:start_date].blank? ? Date.new(0) : Date.strptime(params[:start_date], "%Y-%m-%d")
          # set end_date to either passed param or now
          end_date = params[:end_date].blank? ? Date.today : Date.strptime(params[:end_date], "%Y-%m-%d")

          filtered = []
          objects.each do |obj|
            # apperantly things can have nil created_at
            if obj.created_at.blank?
              if params[:start_date].blank? && params[:end_date].blank?
                filtered += [obj]
              end
            elsif start_date <= obj.created_at.to_date && end_date >= obj.created_at.to_date
              filtered += [obj]
            end
          end
          return filtered
        end
    end
  end
end