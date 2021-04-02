# frozen_string_literal: true

class MadmpCodebaseController < ApplicationController

  after_action :verify_authorized

  def run
    @fragment = MadmpFragment.find(params[:fragment_id])
    script_id = params[:script_id]

    response = ExternalApis::MadmpCodebaseService.run(script_id, body:
      {
        "data": @fragment.data,
        "schema": {},
        "dmp_id": @fragment.dmp_id
      })

    authorize @fragment
    render json: response.to_json
  end

end
