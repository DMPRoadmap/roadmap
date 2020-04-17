module SuperAdmin
  class StructuredDataSchemasController < ApplicationController

    # GET /structured_data_schemas
    def index
      authorize(StructuredDataSchema)
      render(:index, locals: { structured_data_schemas: StructuredDataSchema.all.page(1) })
    end

    def new
      authorize(StructuredDataSchema)
      @schema = StructuredDataSchema.new
    end

    def create
      authorize(StructuredDataSchema)
      @schema = StructuredDataSchema.new(permitted_params)
      if @schema.save
        flash.now[:notice] = success_message(@schema, _("created"))
        render :edit
      else
        flash.now[:alert] = failure_message(@schema, _("create"))
        render :new
      end
    end
  
    def edit
      authorize(StructuredDataSchema)
      @schema = StructuredDataSchema.find(params[:id])
    end


    def update
      authorize(StructuredDataSchema)
      @schema = StructuredDataSchema.find(params[:id])
      if @schema.update_attributes(permitted_params)
        flash.now[:notice] = success_message(@schema, _("updated"))
      else
        flash.now[:alert] = failure_message(@schema, _("update"))
      end
      render :edit
    end

    def destroy
      authorize(StructuredDataSchema)
      @schema = StructuredDataSchema.find(params[:id])
      if @schema.destroy
        msg = success_message(@schema, _("deleted"))
        redirect_to super_admin_structured_data_schemas_path, notice: msg
      else
        flash.now[:alert] = failure_message(@schema, _("delete"))
        redner :edit
      end
    end


    # Private instance methods
    private

    def permitted_params
      params.require(:structured_data_schema).permit(:label, :name, :version, :classname, :schema)
    end
    
  end
end