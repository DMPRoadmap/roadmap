# frozen_string_literal: true

# Controller for the MadmpCodebase Service, that handles clicks on Runs buttons
class MadmpCodebaseController < ApplicationController
  after_action :verify_authorized

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def run
    fragment = MadmpFragment.find(params[:fragment_id])
    script_name = params[:script_name]
    schema_run = fragment.madmp_schema.extract_run_parameters(script_name:)
    script_params = schema_run['params'] || {}
    script_owner = schema_run['owner'] || nil

    authorize fragment

    # EXAMPLE DATA
    # file_path = Rails.root.join("engines/madmp_opidor/config/example_data/codebase_example_data.json")
    # response = JSON.load(File.open(file_path))
    # fragment.raw_import(response, fragment.madmp_schema)
    # render json: {
    #   'fragment' => fragment.get_full_fragment(with_ids: true),
    #   'needs_reload' => true
    # }, status: 200
    # return
    # render json: {
    #   'message' => _('Notification has been sent'),
    #   'needs_reload' => false
    # }, status: 200
    # return

    fragment.plan.add_api_client!(fragment.madmp_schema.api_client) if script_name.include?('notifyer')
    begin
      response = fetch_run_data(fragment, script_name, script_owner, body: {
        data: fragment.data,
        schema: fragment.madmp_schema.schema,
        dmp_language: fragment.dmp.locale,
        dmp_id: fragment.dmp_id,
        research_output_id: fragment.research_output_fragment&.id,
        params: script_params.merge({ ro_uuid: fragment.research_output&.uuid })
      })

      if response['return_code'].eql?(0)
        if response['data'].empty?
          render json: {
            'message' => _('Notification has been sent'),
            'needs_reload' => false
          }, status: 200
        else
          fragment.import_with_instructions(response['data'], fragment.madmp_schema)
          render json: {
            'fragment' => fragment.get_full_fragment(with_ids: true),
            'needs_reload' => true
          }, status: 200
        end
        update_run_log(fragment, script_name)
      else
        # Rails.cache.delete(["codebase_run", fragment.id])
        render json: {
          'error' => "#{_('An error has occured: ')} #{response['result_message']}"
        }, status: 500
      end
    rescue StandardError => e
      # Rails.cache.delete(["codebase_run", fragment.id])
      render json: {
        'error' => e.message
      }, status: 500
    end
  end
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def project_search
    project_id = params[:project_id]
    fragment = MadmpFragment.find(params[:fragment_id])
    dmp_fragment = fragment.dmp
    script_name = params[:script_name]

    authorize fragment
    # EXAMPLE DATA
    # begin
    #   file_path = Rails.root.join("engines/madmp_opidor/config/example_data/anr_example_data.json")
    #   response = JSON.load(File.open(file_path))
    #   dmp_fragment.raw_import(response, dmp_fragment.madmp_schema)
    #   dmp_fragment.update_meta_fragment

    #   render json: {
    #     'fragment' => dmp_fragment.get_full_fragment,
    #     'persons' => dmp_fragment.persons.map do |f|
    #       {
    #         **f.get_full_fragment(with_ids: true),
    #         'to_string' => f.to_s,
    #       }
    #     end,
    #     "message" => _('New data have been added to your plan, please click on the "Reload" button.')
    #   }, status: 200
    # rescue StandardError => e
    #   # Rails.cache.delete(["codebase_run", fragment.id])
    #   render json: {
    #     'error' => "Internal Server error: #{e.message}"
    #   }, status: 500
    # end
    # return

    begin
      response = fetch_run_data(fragment, script_name, 'superadmin', body: {
        data: { grantId: project_id },
        dmp_language: fragment.dmp.locale,
        # schema: fragment.madmp_schema.schema,
        # dmp_id: fragment.dmp_id,
        # research_output_id: fragment.research_output_fragment&.id,
        # params: params.merge({ ro_uuid: fragment.research_output&.uuid })
      }, params: {})

      if response['return_code'].eql?(0)
        dmp_fragment.raw_import(response['data'], dmp_fragment.madmp_schema)
        dmp_fragment.update_meta_fragment
        render json: {
          'fragment' => dmp_fragment.get_full_fragment(with_ids: true),
          'persons' => dmp_fragment.persons.map do |f|
            {
              **f.get_full_fragment(with_ids: true),
              'to_string' => f.to_s,
            }
          end,
          'plan_title' => dmp_fragment.meta.data['title'],
          'message' => _('Project data have successfully been imported.')
        }, status: 200
        update_run_log(dmp_fragment, script_name)
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

  def fetch_run_data(fragment, script_name, script_owner = 'superadmin', body: {}, params: {})
    return {} unless fragment.present? && script_name.present?

    ExternalApis::MadmpCodebaseService.run(script_name, script_owner, body:)
  end

  def update_run_log(fragment, script_name)
    runned_scripts = fragment.additional_info['runned_scripts'] || {}
    runned_scripts[script_name] = Time.now
    fragment.additional_info = fragment.additional_info.merge(
      'runned_scripts' => runned_scripts
    )
    fragment.save
  end
end
