# frozen_string_literal: true

class OrgIndicesController < ApplicationController

  # GET orgs/search
  def search
    term = org_index_params.fetch(:org_index, {})[:name]
    if term.length > 2
      render json: OrgIndex.search(
        term, org_index_params[:known_only] == "true", org_index_params[:funder_only] == "true"
      )
    else
      render json: []
    end
  end

  private

  def org_index_params
    params.permit(%i[known_only funder_only non_funder_only context], org_index: :name)
  end

end
