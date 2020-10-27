module SuperAdmin
  class MadmpSchemasController < ApplicationController

    before_action :set_schema, only: %i[edit update destroy]
    before_action :substitute_names, only: [:update]

    # GET /madmp_schemas
    def index
      authorize(MadmpSchema)
      render(:index, locals: { madmp_schemas: MadmpSchema.all.page(1) })
    end

    def new
      authorize(MadmpSchema)
      @schema = MadmpSchema.new
    end

    def create
      authorize(MadmpSchema)
      @schema = MadmpSchema.new(permitted_params)
      if @schema.save
        flash.now[:notice] = success_message(@schema, _("created"))
        render :edit
      else
        flash.now[:alert] = failure_message(@schema, _("create"))
        render :new
      end
    end
  
    def edit
      authorize(MadmpSchema)
    end


    def update
      authorize(MadmpSchema)
      if @schema.update_attributes(permitted_params)
        flash.now[:notice] = success_message(@schema, _("updated"))
      else
        flash.now[:alert] = failure_message(@schema, _("update"))
      end
      render :edit
    end

    def destroy
      authorize(MadmpSchema)
      if @schema.destroy
        msg = success_message(@schema, _("deleted"))
        redirect_to super_admin_madmp_schemas_path, notice: msg
      else
        flash.now[:alert] = failure_message(@schema, _("delete"))
        redner :edit
      end
    end


    # Private instance methods
    private

    # Set the @schema var
    def set_schema
      @schema = MadmpSchema.find(params[:id])
    end

    # Substitute "template_name" key/values for their "schema_id" equivalent in the JSON
    def substitute_names
      # Get the actual JSON schema from the params
      json_data = permitted_params[:schema]

      # Find and replace the values
      json_data = JsonPath.for(json_data).gsub('$..template_name') do |name|
        MadmpSchema.find_by!(name: name).id
      end.to_json

      # Replace the key names
      json_data = json_data.gsub('template_name', 'schema_id')

      # Update the params
      params[:madmp_schema][:schema] = json_data
    end

    def permitted_params
      params.require(:madmp_schema).permit(:label, :name, :version, :classname, :schema)
    end
    
  end
end