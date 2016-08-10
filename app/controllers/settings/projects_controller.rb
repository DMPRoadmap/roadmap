module Settings
  class ProjectsController < SettingsController

    before_filter :get_plan_list_columns
    before_filter :get_settings

    def show
      respond_to do |format|
        format.html
        format.json { render json: settings_json }
      end
    end

    def update
      columns = (params[:columns] || {})

      if @settings.update_attributes(columns: columns)
        respond_to do |format|
          format.html { redirect_to(projects_path) }
          format.json { render json: settings_json }
        end
      else
        render(action: :show) # Expect #show to display errors etc
      end
    end

  private

    def get_settings
      @settings = current_user.settings(:plan_list)
      # :name column should always be present (displayed as a disabled checkbox)
      # so it's not necessary to include it in the list here
      @all_columns -= [:name]
    end

    def settings_json
      @settings_json ||= { selected_columns: @settings.columns, all_columns: @all_columns }.to_json
    end
  end
end
