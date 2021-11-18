# frozen_string_literal: true
class Api::V0::Madmp::MadmpSchemasController < Api::V0::BaseController

  before_action :authenticate

  def show
    @schema = MadmpSchema.find(params[:id])
    # check if the user has permissions to use the templates API
    unless Api::V0::Madmp::MadmpSchemaPolicy.new(@user, @fragment).show?
      raise Pundit::NotAuthorizedError
    end

    respond_with @schema.schema
  end
end
