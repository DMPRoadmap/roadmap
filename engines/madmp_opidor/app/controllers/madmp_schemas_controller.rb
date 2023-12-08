# frozen_string_literal: true

# Controller for the MadmpSchemas, handle structures forms
class MadmpSchemasController < ApplicationController
  after_action :verify_authorized

  def index
    authorize(MadmpSchema)
    render json: MadmpSchema.where(classname: params[:by_classname]).select(%w[id label schema])
  end
  def show
    authorize(MadmpSchema)
    @schema = MadmpSchema.find(params[:id]).schema
    render json: @schema
  end
end
