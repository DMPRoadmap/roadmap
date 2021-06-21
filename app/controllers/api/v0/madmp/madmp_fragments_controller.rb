# frozen_string_literal: true
require "jsonpath"

class Api::V0::Madmp::MadmpFragmentsController < Api::V0::BaseController

  before_action :authenticate
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def show
    @fragment = MadmpFragment.find(params[:id])
    # check if the user has permissions to use the API
    unless Api::V0::Madmp::MadmpFragmentPolicy.new(@user, @fragment).show?
      raise Pundit::NotAuthorizedError
    end

    fragment_data = query_params[:mode] == "fat" ? @fragment.get_full_fragment(with_ids: true) : @fragment.data

    fragment_data = select_property(fragment_data, query_params[:property])

    render json: {
      "data" => fragment_data,
      "dmp_id" => @fragment.dmp_id,
      "schema" => @fragment.madmp_schema.schema
    }
  end

  def update
    @fragment = MadmpFragment.find(params[:id])

    # check if the user has permissions to use the API
    unless Api::V0::Madmp::MadmpFragmentPolicy.new(@user, @fragment).update?
      raise Pundit::NotAuthorizedError
    end

    @fragment.save_api_fragment(params[:data], @fragment.madmp_schema)

    render json: {
      "data" => @fragment.data,
      "dmp_id" => @fragment.dmp_id,
      "schema" => @fragment.madmp_schema.schema
    }
  end

  ## NEEDS ERROR MANAGEMENT
  def dmp_fragments
    @dmp_fragment = Fragment::Dmp.find(params[:id])
    @dmp_fragments = MadmpFragment.where(dmp_id: @dmp_fragment.id).order(:id).map do |f|
      {
        "id" => f.id,
        "data" => f.data,
        "schema" => f.madmp_schema.schema
      }
    end
    @dmp_fragments.unshift({
      "id" => @dmp_fragment.id,
      "data" => @dmp_fragment.data,
      "schema" => @dmp_fragment.madmp_schema.schema
    })
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

  def record_not_found
    render json: {
      "error" => d_("dmpopidor", "Fragment with id %{id} doesn't exist.") % { id: params[:id] }
    }, status: 404
  end
end
