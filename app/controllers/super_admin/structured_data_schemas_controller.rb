module SuperAdmin
  class StructuredDataSchemasController < ApplicationController

    # GET /structured_data_schemas
    def index
      authorize(StructuredDataSchema)
      render(:index, locals: { structured_data_schemas: StructuredDataSchema.all.page(1) })
    end

    # GET /structured_data_schemas/1/edit
    def edit
      authorize(StructuredDataSchema)
    end
    
  end
end