# frozen_string_literal: true
require "jsonpath"

class Api::V0::Madmp::MadmpFragmentsController < Api::V0::BaseController

  before_action :authenticate

  def show
    @fragment = MadmpFragment.find(params[:id])
    # check if the user has permissions to use the templates API
    unless Api::V0::Madmp::MadmpFragmentPolicy.new(@user, @fragment).show?
      raise Pundit::NotAuthorizedError
    end

    fragment_data = query_params[:mode] == "fat" ? @fragment.get_full_fragment(true) : @fragment.data

    fragment_data = select_property(fragment_data, query_params[:property])

    render json: {
      "data" => fragment_data,
      "dmp_id" => @fragment.dmp_id,
      "schema" => @fragment.madmp_schema.schema
    }
  end

  ## NEEDS ERROR MANAGEMENT
  def dmp_fragments
    @dmp_fragment = Fragment::Dmp.find(params[:id])
    @dmp_fragments = MadmpFragment.where(dmp_id: @dmp_fragment.id).map do |f|
      {
        "id" => f.id,
        "data" => f.data,
        "schema" => f.madmp_schema.schema
      }
    end

    render json: {
      "dmp_id" => @dmp_fragment.id,
      "data" => @dmp_fragments,
      "schema" => @dmp_fragment.madmp_schema.schema
    }
  end

  private

  def select_property(fragment_data, property_name)
    if property_name.present?
      fragment_data = JsonPath.on(fragment_data, "$..#{property_name}")
    end
    fragment_data
  end

  def query_params
    params.permit(:mode, :property)
  end

end
