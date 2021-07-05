# frozen_string_literal: true

class MadmpCodebaseController < ApplicationController

  after_action :verify_authorized

  def run
    fragment = MadmpFragment.find(params[:fragment_id])
    script_id = params[:script_id]

    authorize fragment

    # EXAMPLE DATA
    # file_path = Rails.root.join("config/madmp/schemas/codebase_example_data.json")
    # response = JSON.load(File.open(file_path))
    # fragment.save_codebase_fragment(response, fragment.madmp_schema)
    # render json: {
    #   "message" => d_("dmpopidor", 'New data have been added to your plan, please click on the "Reload" button.')
    # }, status: 200
    # return
    begin
      response = fetch_run_data(fragment, script_id)
      if response["return_code"]&.eql?(0)
        if response["data"].empty?
          render json: {
            "message" => d_("dmpopidor", "Notification has been sent"),
            "needs_reload" => false
          }, status: 200
        else
          fragment.save_codebase_fragment(response["data"], fragment.madmp_schema)
          render json: {
            "message" => d_("dmpopidor", 'New data have been added to your plan, please click on the "Reload" button.'),
            "needs_reload" => true
          }, status: 200
        end
        update_run_log(fragment, script_id)
      else
        # Rails.cache.delete(["codebase_run", fragment.id])
        render json: {
          "error" => "#{d_('dmpopidor', 'An error has occured: ')} #{response['result_message']}"
        }, status: 500
      end
    rescue StandardError => e
      # Rails.cache.delete(["codebase_run", fragment.id])
      render json: {
        "error" => "Internal Server error: #{e.message}"
      }, status: 500
    end
  end

  def anr_search
    anr_project_id = params[:project_id]
    fragment = MadmpFragment.find(params[:fragment_id])
    script_id = params[:script_id]

    authorize fragment
    # EXAMPLE DATA
    # file_path = Rails.root.join("config/madmp/schemas/anr_example_data.json")
    # response = JSON.load(File.open(file_path))
    # fragment.save_api_fragment(response, fragment.madmp_schema)
    # render json: {
    #   "message" => d_("dmpopidor", 'New data have been added to your plan, please click on the "Reload" button.')
    # }, status: 200
    # return

    begin
      response = ExternalApis::MadmpCodebaseService.run(script_id, body:
        {
          "data": anr_project_id,
          "dmp_id": fragment.dmp_id
        }
      )
      if response["return_code"]&.eql?(0)
        fragment.save_codebase_fragment(response["data"], fragment.madmp_schema)
        render json: {
          "message" => d_("dmpopidor", 'New data have been added to your plan, please click on the "Reload" button.'),
          "needs_reload" => true
        }, status: 200
        update_run_log(fragment, script_id)
      else
        # Rails.cache.delete(["codebase_run", fragment.id])
        render json: {
          "error" => "#{d_('dmpopidor', 'An error has occured: ')} #{response['result_message']}"
        }, status: 500
      end
    rescue StandardError => e
      # Rails.cache.delete(["codebase_run", fragment.id])
      render json: {
        "error" => "Internal Server error: #{e.message}"
      }, status: 500
    end
  end

  private

  def fetch_run_data(fragment, script_id)
    return {} unless fragment.present? && script_id.present?

    ExternalApis::MadmpCodebaseService.run(script_id, body:
      {
        "data": fragment.data,
        "schema": {},
        "dmp_id": fragment.dmp_id,
        "research_output_id": fragment.research_output_fragment&.id
      }
    )
  end

  def update_run_log(fragment, script_id)
    runned_scripts = fragment.additional_info["runned_scripts"] || {}
    runned_scripts[script_id.to_s] = Time.now
    fragment.additional_info = fragment.additional_info.merge(
      "runned_scripts" => runned_scripts
    )
    fragment.save
  end

end
