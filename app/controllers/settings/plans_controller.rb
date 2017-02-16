module Settings
  class PlansController < SettingsController

    before_filter :get_plan_list_columns
    before_filter :get_settings

    after_action :verify_authorized

    def show
      authorize [:settings, @plan]
      respond_to do |format|
        format.html
        format.partial
        format.json{ render json: settings_json }
      end
    end

    def update
      authorize @plan
      export_params = params[:export].try(:deep_symbolize_keys)

      settings = @plan.super_settings(:export).tap do |s|
        if params[:commit] == 'Reset'
          s.formatting = nil
          s.fields = nil
        else
          s.formatting = export_params[:formatting]
          s.fields = export_params[:fields]
          s.title  = export_params[:title]
        end
      end

      if settings.save
        respond_to do |format|
          format.html { redirect_to(export_project_path(@plan.project)) }
        end
      else
        settings.formatting = nil
        @export_settings = settings
        render(action: :show)
      end
    end

  private

    def get_settings
      @plan = Plan.find(params[:id])
      
      @export_settings = plan.settings(:export)
    end

    def settings_json
      @settings_json ||= { export: @export_settings }.to_json
    end

    def plan
      @plan ||= Plan.find(params[:id])
    end

  end
end
