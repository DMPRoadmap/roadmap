# frozen_string_literal: true

module SuperAdmin
  # Controller for managing MadmpSchemas
  class MadmpSchemasController < ApplicationController
    before_action :set_schema, only: %i[edit update destroy]

    # GET /madmp_schemas
    def index
      authorize(MadmpSchema)
      render(:index, locals: { madmp_schemas: MadmpSchema.all.page(1) })
    end

    def new
      authorize(MadmpSchema)
      @schema = MadmpSchema.new
    end

    # rubocop:disable Metrics/AbcSize
    def create
      authorize(MadmpSchema)
      @schema = MadmpSchema.new(permitted_params.except(:schema))
      if @schema.save
        @schema.update(schema: permitted_params[:schema])
        flash.now[:notice] = success_message(@schema, _('created'))
        render :edit
      else
        flash.now[:alert] = failure_message(@schema, _('create'))
        render :new
      end
    end
    # rubocop:enable Metrics/AbcSize

    def edit
      authorize(MadmpSchema)
    end

    # rubocop:disable Metrics/AbcSize
    def update
      authorize(MadmpSchema)
      if @schema.update(permitted_params.except(:schema))
        @schema.update_column(:schema, permitted_params[:schema])
        flash.now[:notice] = success_message(@schema, _('updated'))
      else
        flash.now[:alert] = failure_message(@schema, _('update'))
      end
      render :edit
    end
    # rubocop:enable Metrics/AbcSize

    def destroy
      authorize(MadmpSchema)
      if @schema.destroy
        msg = success_message(@schema, _('deleted'))
        redirect_to super_admin_madmp_schemas_path, notice: msg
      else
        flash.now[:alert] = failure_message(@schema, _('delete'))
        render :edit
      end
    end

    # Private instance methods
    private

    # Set the @schema var
    def set_schema
      @schema = MadmpSchema.find(params[:id])
    end

    def load_schema(schema_file, schema)
      return if schema_file.nil?

      if schema_file.respond_to?(:read)
        schema_data = schema_file.read
      elsif schema_file.respond_to?(:path)
        schema_data = File.read(schema_file.path)
      else
        logger.error "Bad schema_file: #{schema_file.class.name}: #{schema_file.inspect}"
      end
      json_schema = JSON.parse(schema_data)
      schema.update(schema: json_schema.to_json)
    end

    def permitted_params
      params.require(:madmp_schema).permit(:label, :name, :version, :classname, :api_client_id, :schema)
    end
  end
end
