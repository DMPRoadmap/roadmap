# frozen_string_literal: true

class MadmpCodebaseController < ApplicationController

  after_action :verify_authorized

  def run
    fragment = MadmpFragment.find(params[:fragment_id])
    script_id = params[:script_id]

    authorize fragment

    begin
      response = fetch_run_data(fragment, script_id)
      if response["return_code"]&.eql?(0)
        # EXAMPLE DATA : CODEBASE NEEDS FIXES
        # file_path = Rails.root.join("config/schemas/codebase_example_data.json")
        # response = JSON.load(File.open(file_path))
        # fragment.save_codebase_fragment(response, fragment.madmp_schema)
        fragment.save_codebase_fragment(response["data"], fragment.madmp_schema)
        render json: {
          "message" => d_("dmpopidor", 'New data have been added to your plan, please click on the "Reload" button.')
        }, status: 200
      else
        render json: {
          "error" => "#{d_('dmpopidor', 'An error has occured: ')} #{response['result_message']}"
        }, status: 500
      end
    rescue StandardError
      render json: {
        "error" => "Internal Server error"
      }, status: 500
    end
  end

  private

  def fetch_run_data(fragment, script_id)
    return {} unless fragment.present? && script_id.present?

    Rails.cache.fetch(["codebase_run", fragment.id], expires_in: 86_400) do
      ExternalApis::MadmpCodebaseService.run(script_id, body:
        {
          "data": fragment.data,
          "schema": {},
          "dmp_id": fragment.dmp_id
        })
    end
  end

end
