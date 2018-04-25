module Api
  module V0
    class StatisticsController < Api::V0::BaseController
      before_action :authenticate

      # GET /api/v0/statistics/users_joined?start_date=&end_date=&org_id=
      # Returns the number of users joined for the user's org.
      # If start_date is passed, only counts those with created_at is >= than start_date
      # If end_date is passed, only counts those with created_at is <= than end_date are
      # If org_id is passed and user has super_admin privileges that counter is performed against org_id param instead of user's org
      # @return
      def users_joined
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).users_joined?

        if @user.can_super_admin? && params[:org_id].present?
          scoped = User.unscoped.where(org_id: params[:org_id])
        else
          scoped = User.unscoped.where(org_id: @user.org_id)
        end

        if params[:range_dates].present?
          r = {}
          params[:range_dates].each_pair do |k, v|
           r[k] = scoped
           .where('created_at >=?', v['start_date'])
           .where('created_at <=?', v['end_date']).count
          end
          respond_to do |format|
            format.json { render(json: r.to_json) }
            format.csv {
              send_data(CSV.generate do |csv|
                csv << [_('Month'), _('No. Users joined')]
                total = 0
                r.each_pair{ |k,v| csv << [k,v]; total+=v }
                csv << [_('Total'), total]
              end, filename: "#{_('users_joined')}.csv") }
          end
        else
          scoped = scoped.where('created_at >= ?', Date.parse(params[:start_date])) if params[:start_date].present?
          scoped = scoped.where('created_at <= ?', Date.parse(params[:end_date])) if params[:end_date].present?
          @users_count = scoped.count
          respond_with @users_count
        end
      end
      # GET
      # Returns the number of completed plans within the user's org for the data start_date and end_date specified
      def completed_plans
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).completed_plans?

        roles = Role.where("#{Role.creator_condition} OR #{Role.administrator_condition}")

        users = User.unscoped
        if @user.can_super_admin? && params[:org_id].present?
          users = users.where(org_id: params[:org_id])
        else
          users = users.where(org_id: @user.org_id)
        end

        plans = Plan.where(complete: true)
        if params[:range_dates].present?
          r = {}
          params[:range_dates].each_pair do |k, v|
            range_date_plans = plans
              .where('plans.updated_at >=?', v['start_date'])
              .where('plans.updated_at <=?', v['end_date'])
            r[k] = roles.joins(:user, :plan).merge(users).merge(range_date_plans).select(:plan_id).distinct.count
          end
          respond_to do |format|
            format.json { render(json: r.to_json) }
            format.csv {
              send_data(CSV.generate do |csv|
                csv << [_('Month'), _('No. Completed Plans')]
                total = 0
                r.each_pair{ |k,v| csv << [k,v]; total+=v }
                csv << [_('Total'), total]
              end, filename: "#{_('completed_plans')}.csv") }
          end
        else
          plans = plans.where('plans.updated_at >= ?', Date.parse(params[:start_date])) if params[:start_date].present?
          plans = plans.where('plans.updated_at <= ?', Date.parse(params[:end_date])) if params[:end_date].present?
          count = roles.joins(:user, :plan).merge(users).merge(plans).select(:plan_id).distinct.count
          render(json: { completed_plans: count })
        end
      end

      # /api/v0/statistics/created_plans
      # Returns the number of created plans within the user's org for the data start_date and end_date specified
      def created_plans
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans?

        roles = Role.where("#{Role.creator_condition} OR #{Role.administrator_condition}")

        users = User.unscoped
        if @user.can_super_admin? && params[:org_id].present?
          users = users.where(org_id: params[:org_id])
        else
          users = users.where(org_id: @user.org_id)
        end

        plans = Plan.all
        if params[:range_dates].present?
          r = {}
          params[:range_dates].each_pair do |k, v|
            range_date_plans = plans
              .where('plans.created_at >=?', v['start_date'])
              .where('plans.created_at <=?', v['end_date'])
            r[k] = roles.joins(:user, :plan).merge(users).merge(range_date_plans).select(:plan_id).distinct.count
          end
          respond_to do |format|
            format.json { render(json: r.to_json) }
            format.csv {
              send_data(CSV.generate do |csv|
                csv << [_('Month'), _('No. Plans')]
                total = 0
                r.each_pair{ |k,v| csv << [k,v]; total+=v }
                csv << [_('Total'), total]
              end, filename: "#{_('plans')}.csv") }
          end
        else
          plans = plans.where('plans.created_at >= ?', Date.parse(params[:start_date])) if params[:start_date].present?
          plans = plans.where('plans.created_at <= ?', Date.parse(params[:end_date])) if params[:end_date].present?
          count = roles.joins(:user, :plan).merge(users).merge(plans).select(:plan_id).distinct.count
          render(json: { created_plans: count })
        end
      end

      ##
      # GET
      # @return the number of DMPs using the specified template between the optional specified dates
      # ensures that the template is owned/created by the caller's organisation
      def using_template
        org_templates = @user.org.templates.where(customization_of: nil)
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, org_templates.first).using_template?
        @templates = {}
        org_templates.each do |template|
          if @templates[template.title].blank?
            @templates[template.title] = {}
            @templates[template.title][:title]  = template.title
            @templates[template.title][:id]     = template.family_id
            if template.plans.present?
              @templates[template.title][:uses] = restrict_date_range(template.plans).length
            else
              @templates[template.title][:uses] = 0
            end
          else
            if template.plans.present?
              @templates[template.title][:uses]  += restrict_date_range(template.plans).length
            end
          end
        end
        respond_with @templates
      end

      ##
      # GET
      # @return a list of templates with their titles, ids, and uses between the optional specified dates
      # the uses are restricted to DMPs created by users of the same organisation
      # as the user who ititiated the call
      def plans_by_template
        raise Pundit::NotAuthorizedError unless Api::V0::StatisticsPolicy.new(@user, :statistics).plans_by_template?
        org_projects = []
        @user.org.users.each do |user|
          user.plans.each do |plan|
            unless org_projects.include? plan
              org_projects += [plan]
            end
          end
        end
        org_projects = restrict_date_range(org_projects)
        @templates = {}
        org_projects.each do |plan|
          # if hash exists
          if @templates[plan.template.title].blank?
            @templates[plan.template.title] = {}
            @templates[plan.template.title][:title] = plan.template.title
            @templates[plan.template.title][:id] = plan.template.family_id
            @templates[plan.template.title][:uses] = 1
          else
            @templates[plan.template.title][:uses] += 1
          end
        end
        respond_with @templates
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
