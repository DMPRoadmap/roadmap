module SuperAdmin
  class MadmpSchemasController < ApplicationController

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
      @schema = MadmpSchema.find(params[:id])
    end


    def update
      authorize(MadmpSchema)
      @schema = MadmpSchema.find(params[:id])
      if @schema.update_attributes(permitted_params)
        flash.now[:notice] = success_message(@schema, _("updated"))
      else
        flash.now[:alert] = failure_message(@schema, _("update"))
      end
      render :edit
    end

    def destroy
      authorize(MadmpSchema)
      @schema = MadmpSchema.find(params[:id])
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

    def permitted_params
      params.require(:madmp_schema).permit(:label, :name, :version, :classname, :schema)
    end
    
  end
end