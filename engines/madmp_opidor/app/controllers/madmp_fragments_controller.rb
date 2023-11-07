# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# Controller for the MadmpFragments, handle structures forms
class MadmpFragmentsController < ApplicationController
  after_action :verify_authorized
  include Dmpopidor::ErrorHelper

  # KEEP IN V4

  def create
    body = JSON.parse(request.body.string)
    plan = ::Plan.includes(:template).find(body["plan_id"])
    schema = MadmpSchema.find(body["schema_id"])
    defaults = schema.defaults(plan.template.locale)
    classname = schema.classname
    @fragment = MadmpFragment.new(
      data: body["data"],
      dmp_id: plan.json_fragment.id,
      madmp_schema: schema,
      additional_info: {
        'property_name' => body["property_name"]
      }
    )
    @fragment.classname = classname
    authorize @fragment
    unless classname.eql?('person')
      @fragment.answer = ::Answer.create!(
        research_output_id: body["research_output_id"],
        plan_id: plan.id,
        question_id: body["question_id"],
        user_id: current_user.id
      )
      research_output = ::ResearchOutput.find(body["research_output_id"])
      @fragment.parent_id = research_output.json_fragment.id
    end
    @fragment.instantiate
    @fragment.handle_defaults(defaults)

    render json: {
      'fragment' => @fragment.get_full_fragment(with_ids: true),
      'answer_id' => @fragment.answer_id,
      'schema' => @fragment.madmp_schema.schema
    }
  end

  def show
    @fragment = MadmpFragment.find(params[:id])
    authorize @fragment
    render json: {
      'fragment' => @fragment.get_full_fragment(with_ids: true),
      'schema' => @fragment.madmp_schema.schema
    }
  end

  # TODO: will become update
  # Needs some rework
  def update
    @fragment = MadmpFragment.find(params[:id])
    form_data = JSON.parse(request.body.string)
    authorize @fragment

    MadmpFragment.transaction do
      @fragment.import_with_instructions(
        form_data,
        @fragment.madmp_schema
      )

      @fragment.update_meta_fragment
      render json: {
        fragment: @fragment.get_full_fragment(with_ids: true),
        plan_title: (@fragment.dmp.meta.data['title'] if %w[dmp project entity].include?( @fragment.classname)),
        message: _('Form saved successfully.')
      }, status: :ok
    rescue ActiveRecord::StaleObjectError
      render json: {
        message: _('Error when saving form.')
      }, status: :internal_server_error
    end
  end

  # rubocop:disable Metrics/AbcSize
  def load_fragments
    @dmp_fragment = MadmpFragment.find(params[:dmp_id])
    search_term = params[:term] || ''
    where_params = if params[:classname].present?
                     { classname: params[:classname] }
                   else
                     { madmp_schema_id: params[:schema_id] }
                   end
    fragment_list = MadmpFragment.where(dmp_id: @dmp_fragment.id, **where_params)
    formatted_list = fragment_list.select { |f| f.to_s.downcase.include?(search_term) }
                                  .map do |f|
                                    {
                                      **f.get_full_fragment(with_ids: true),
                                      'to_string' => f.to_s,
                                    }
                                  end
    authorize @dmp_fragment
    render json: {
      'results' => formatted_list
    }
  end
  # rubocop:enable Metrics/AbcSize
  

  # rubocop:disable Metrics/AbcSize
  def destroy
    @fragment = MadmpFragment.find(params[:id])
    parent_id = @fragment.parent_id

    authorize @fragment
    if @fragment.destroy
      MadmpFragment.find(parent_id).update_children_references if parent_id.present?
      @fragment = success_message(@fragment, _('removed'))
      render json: { status: 200, message: 'Fragment removed successfully', fragment: @fragment }, status: :ok

    else
      @notice = failure_message(@fragment, _('remove'))
      render bad_request(@notice)
    end
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def destroy_contributor
    @person = Fragment::Person.find(params[:contributor_id])
    contributors_list = @person.contributors
    dmp_id = @person.dmp_id
    property_name = @person.additional_info['property_name']

    authorize @person.becomes(MadmpFragment)
    if @person.destroy
      contributors_list.each { |c| c.destroy }

      @person = success_message(@person, _('removed'))
      render json: { status: 200, message: 'Contributor removed successfully', fragment: @person }, status: :ok

    else
      @notice = failure_message(@person, _('remove'))
      render bad_request(@notice)
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength


  private

  # Since the StaleObjectError is triggered on the Answer we need to recover the
  # MadmpFragment data from the form, because the stale MadmpFragment has not yet been modified
  # This method takes the form data and remove every "sub fragment" data so it can be merged
  # to the real fragment data (with dbids)
  # rubocop:disable Metrics/AbcSize,  Metrics/CyclomaticComplexity
  def stale_data(form_data, schema)
    stale_data = {}
    form_data.each do |prop, content|
      schema_prop = schema.properties[prop]

      next if schema_prop&.dig('type').nil?
      next if schema_prop['type'].eql?('object') &&
              schema_prop['schema_id'].present?
      next if schema_prop['type'].eql?('array') &&
              schema_prop['items']['schema_id'].present?

      stale_data[prop] = content
    end
    stale_data
  end
  # rubocop:enable Metrics/AbcSize,  Metrics/CyclomaticComplexity

  # Get the parameters conresponding to the schema
  def schema_params(schema, flat: false)
    s_params = schema.generate_strong_params(flat:)
    params.require(:madmp_fragment).permit(s_params)
  end

  def permitted_params
    permit_arr = [:id, :dmp_id, :parent_id, :schema_id, :source, :template_locale,
                  :property_name, :query_id,
                  {
                    answer: %i[id plan_id research_output_id question_id lock_version is_common]
                  }]
    params.require(:madmp_fragment).permit(permit_arr)
  end
end
# rubocop:enable Metrics/ClassLength
