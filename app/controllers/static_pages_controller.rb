class StaticPagesController < ApplicationController

  def about_us
		dcc_news_feed_url = "http://www.dcc.ac.uk/news/dmponline-0/feed"
		@dcc_news_feed = Feedjira::Feed.fetch_and_parse dcc_news_feed_url
		respond_to do |format|
			format.rss { redirect_to dcc_news_feed_url }
			format.html
		end
  end

  def contact_us
  end

  def roadmap
  end
  
  # GET /plans/publicly_available
  # -----------------------------------------------------------
  def public_plans
    @plans = Plan.where(visibility: :publicly_visible).order(title: :asc)
  end

  # GET /plans/[:plan_slug]/public_export
  # -------------------------------------------------------------
  def public_export
    @plan = Plan.find(params[:id])
  
    # Force PDF response 
    request.format = :pdf
  
    # if the project is designated as public
    if @plan.visibility == :publicly_visible
      if !@plan.nil?
        @exported_plan = ExportedPlan.new.tap do |ep|
          ep.plan = @plan
          ep.user = current_user ||= nil
          #ep.format = request.format.try(:symbol)
          ep.format = request.format.to_sym
          plan_settings = @plan.settings(:export)

          Settings::Dmptemplate::DEFAULT_SETTINGS.each do |key, value|
            ep.settings(:export).send("#{key}=", plan_settings.send(key))
          end
        end

        @exported_plan.save! # FIXME: handle invalid request types without erroring?
        file_name = @exported_plan.project_name

        respond_to do |format|
          format.pdf do
            @formatting = @plan.settings(:export).formatting
            render pdf: file_name,
                   margin: @formatting[:margin],
                   footer: {
                     center: t('helpers.plan.export.pdf.generated_by'),
                     font_size: 8,
                     spacing: (@formatting[:margin][:bottom] / 2) - 4,
                     right: '[page] of [topage]'
                   }
          end
        end

      else
        # the project has no plans for some reason
        redirect_to public_plans_path, notice: I18n.t('helpers.settings.projects.errors.no_plan')
      end
    else
      # Otherwise redirect to the home page with an unauthorized message
      redirect_to public_plans_path, notice: I18n.t('helpers.settings.plans.errors.no_access_account')
    end
  end
end