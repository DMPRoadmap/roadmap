# frozen_string_literal: true

# Controller for the MadmpSchemas, handle structures forms
class MadmpSchemasController < ApplicationController
  after_action :verify_authorized

  def index
    authorize(MadmpSchema)
    render json: MadmpSchema.where(classname: params[:by_classname]).select(%w[id name label schema])
  end
  def show
    authorize(MadmpSchema)
    @schema = MadmpSchema.find(params[:id])
    render json: serialize_json_response(@schema)
  end

  def by_name
    authorize(MadmpSchema)
    @schema = MadmpSchema.find_by(name: params[:name])

    if @schema.present?
      render json: serialize_json_response(@schema)
    else
      render status: :not_found,
             json: { message: _('%{template_name} form is unavailable.' % { template_name: params[:name] }) }
    end
  end

  private

  def serialize_json_response(schema) 
    {
      id: schema.id,
      name: schema.name,
      schema: schema.schema,
      api_client: if schema.api_client.present?
        {
          id: schema.api_client_id,
          name: schema.api_client.name
        } 
      end
    }
  end
end
