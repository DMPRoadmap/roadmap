# frozen_string_literal: true

module Settings

  class PlansController < SettingsController

    before_action :retrieve_settings

    after_action :verify_authorized

    def show
      authorize [:settings, @plan]
      respond_to do |format|
        format.html
        format.partial
        format.json { render json: settings_json }
      end
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize @plan
      # If this is actually used we should consider switching these to strong params
      export_params = params[:export].try(:deep_symbolize_keys)

      settings = @plan.super_settings(:export).tap do |s|
        if params[:commit] == "Reset"
          s.formatting = nil
          s.fields = nil
          s.title = nil
        else
          s.formatting = export_params[:formatting]
          s.fields = export_params[:fields]
          s.title  = export_params[:title]
        end
      end

      if settings.save
        flash[:notice] = _("Export settings updated successfully.")
      else
        flash[:alert] = _("An error has occurred while saving/resetting your export settings.")

      end
      respond_to do |format|
        @phase_options = @plan.phases.order(:number).pluck(:title, :id)
        format.html { redirect_to(download_plan_path(@plan.id)) }
        # format.json { render json: settings_json }
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def retrieve_settings
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
