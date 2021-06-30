# frozen_string_literal: true

class OrgIndicesController < ApplicationController

  # GET orgs/search
  def search
    term = org_index_params.fetch(:org, {})[:name]
    orgs = OrgIndex.search(
      term, org_index_params[:known_only] == "true", org_index_params[:funder_only] == "true"
    )
    # If we want to exclude funders then remove them from the results
    #if org_index_params[:non_funder_only]
    #  @orgs = @orgs.reject { |org| org.is_a?(OrgIndex) ? org.fundref_id.present? : org.funder? }
    #end

    # auto-limit the results to 50
    render json: Kaminari.paginate_array(orgs).page(1).per(50)
  end

  private

  def org_index_params
    params.permit(%i[known_only funder_only non_funder_only], org: :name)
  end

end
