# frozen_string_literal: true

# Controller for the MadmpCodebase Service, that handles clicks on Runs buttons
class MadmpCodebaseController < ApplicationController
  after_action :verify_authorized

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def run
    fragment = MadmpFragment.find(params[:fragment_id])
    schema_runs = fragment.madmp_schema.extract_run_parameters
    script_id = params[:script_id]
    params = if schema_runs.is_a?(Array)
               schema_runs.find { |run| run['script_id'] == script_id.to_i }['params'] || {}
             else
               schema_runs['params'] || {}
             end

    authorize fragment

    # EXAMPLE DATA
    # file_path = Rails.root.join("config/madmp/schemas/codebase_example_data.json")
    # response = JSON.load(File.open(file_path))
    # fragment.import_with_instructions(response, fragment.madmp_schema)
    # render json: {
    #   "message" => _('New data have been added to your plan, please click on the "Reload" button.')
    # }, status: 200
    # return
    begin
      response = fetch_run_data(fragment, script_id, params: params)
      if response['return_code'].eql?(0)
        if response['data'].empty?
          render json: {
            'message' => _('Notification has been sent'),
            'needs_reload' => false
          }, status: 200
        else
          fragment.import_with_instructions(response['data'], fragment.madmp_schema)
          render json: {
            'message' => _('New data have been added to your plan, please click on the "Reload" button.'),
            'needs_reload' => true
          }, status: 200
        end
        update_run_log(fragment, script_id)
      else
        # Rails.cache.delete(["codebase_run", fragment.id])
        render json: {
          'error' => "#{_('An error has occured: ')} #{response['result_message']}"
        }, status: 500
      end
    rescue StandardError => e
      # Rails.cache.delete(["codebase_run", fragment.id])
      render json: {
        'error' => "Internal Server error: #{e.message}"
      }, status: 500
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def anr_search
    anr_project_id = params[:project_id]
    fragment = MadmpFragment.find(params[:fragment_id])
    dmp_fragment = fragment.dmp
    script_id = params[:script_id]

    authorize fragment
    # EXAMPLE DATA
    # file_path = Rails.root.join("config/madmp/schemas/anr_example_data.json")
    # response = JSON.load(File.open(file_path))
    # dmp_fragment.raw_import(response, dmp_fragment.madmp_schema)
    # render json: {
    #   "message" => _('New data have been added to your plan, please click on the "Reload" button.')
    # }, status: 200
    # return

    begin
      response = fetch_run_data(fragment, script_id, custom_data: { grantId: anr_project_id })
      if response['return_code'].eql?(0)
        dmp_fragment.raw_import(response['data'], dmp_fragment.madmp_schema)
        render json: {
          'message' => _('New data have been added to your plan, please click on the "Reload" button.'),
          'needs_reload' => true
        }, status: 200
        update_run_log(dmp_fragment, script_id)
      else
        # Rails.cache.delete(["codebase_run", fragment.id])
        render json: {
          'error' => "#{_('An error has occured: ')} #{response['result_message']}"
        }, status: 500
      end
    rescue StandardError => e
      # Rails.cache.delete(["codebase_run", fragment.id])
      render json: {
        'error' => "Internal Server error: #{e.message}"
      }, status: 500
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  private

  def fetch_run_data(fragment, script_id, params: {}, custom_data: nil)
    return {} unless fragment.present? && script_id.present?

    ExternalApis::MadmpCodebaseService.run(script_id, body:
      {
        data: custom_data || fragment.data,
        schema: fragment.madmp_schema.schema,
        dmp_language: fragment.dmp.locale,
        dmp_id: fragment.dmp_id,
        research_output_id: fragment.research_output_fragment&.id,
        params: params
      })
  end

  def update_run_log(fragment, script_id)
    runned_scripts = fragment.additional_info['runned_scripts'] || {}
    runned_scripts[script_id.to_s] = Time.now
    fragment.additional_info = fragment.additional_info.merge(
      'runned_scripts' => runned_scripts
    )
    fragment.save
  end
end
