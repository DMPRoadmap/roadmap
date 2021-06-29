# frozen_string_literal: true

class OrgIndicesController < ApplicationController

  # GET orgs/search
  def search
    term = org_index_params.fetch(:org_index, {})[:name]
    @context = org_index_params[:context]
    @orgs = OrgIndex.search(
      term, org_index_params[:known_only] == "true", org_index_params[:funder_only] == "true"
    )
    # If we want to exclude funders then remove them from the results
    #if org_index_params[:non_funder_only]
    #  @orgs = @orgs.reject { |org| org.is_a?(OrgIndex) ? org.fundref_id.present? : org.funder? }
    #end
  end

  private

  def org_index_params
    params.permit(%i[known_only funder_only non_funder_only context], org_index: :name)
  end

end
