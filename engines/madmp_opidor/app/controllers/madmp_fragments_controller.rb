# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# Controller for the MadmpFragments, handle structures forms
class MadmpFragmentsController < ApplicationController
  after_action :verify_authorized
  include DynamicFormHelper

  # KEEP IN V4

  def create_json
    p_params = permitted_params
    schema = MadmpSchema.find(p_params[:schema_id])
    research_output = ::ResearchOutput.find(p_params[:answer][:research_output_id])
    defaults = schema.defaults(p_params[:template_locale])
    classname = schema.classname
    parent_id = research_output.json_fragment.id unless classname.eql?('person')
    @fragment = MadmpFragment.new(
      dmp_id: p_params[:dmp_id],
      parent_id: parent_id,
      madmp_schema: schema,
      additional_info: {
        'property_name' => p_params[:property_name]
      }
    )
    @fragment.classname = classname
    authorize @fragment

    @fragment.answer = Answer.create!(
      research_output_id: p_params[:answer][:research_output_id],
      plan_id: p_params[:answer][:plan_id],
      question_id: p_params[:answer][:question_id],
      lock_version: p_params[:answer][:lock_version],
      is_common: p_params[:answer][:is_common],
      user_id: current_user.id
    )
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
  def update_json
    @fragment = MadmpFragment.find(params[:id])
    form_data = JSON.parse(request.body.string)
    authorize @fragment

    MadmpFragment.transaction do
      @fragment.import_with_instructions(
        form_data,
        @fragment.madmp_schema
      )
      render json: {
        fragment: @fragment.get_full_fragment(with_ids: true),
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
                                      'id' => f.id,
                                      'text' => f.to_s,
                                      'object' => f.get_full_fragment(with_ids: true)
                                    }
                                  end
    authorize @dmp_fragment
    render json: {
      'results' => formatted_list
    }
  end
  # rubocop:enable Metrics/AbcSize

  # REMOVE IN V4 (?)

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # Method is only called when saving the form in the modal
  def create
    p_params = permitted_params
    @schemas = MadmpSchema.all
    schema = @schemas.find(p_params[:schema_id])
    source = p_params[:source]
    classname = schema.classname
    parent_id = p_params[:parent_id] unless classname.eql?('person')

    data = data_reformater(
      schema,
      schema_params(schema)
    )

    @fragment = MadmpFragment.new(
      dmp_id: p_params[:dmp_id],
      parent_id:,
      madmp_schema: schema,
      additional_info: {
        'property_name' => p_params[:property_name]
      }
    )
    @fragment.classname = classname
    authorize @fragment

    if MadmpFragment.fragment_exists?(data, schema, p_params[:dmp_id], parent_id)
      render json: {
        'error' => _('Element is already present in your plan.')
      }, status: 409
      return
    end

    additional_info = @fragment.additional_info.merge(
      'validations' => MadmpFragment.validate_data(data, schema.schema)
    )
    @fragment.assign_attributes(
      additional_info:
    )
    @fragment.instantiate
    @fragment.save_form_fragment(data, schema)

    if source.eql?('list-modal')
      property_name = @fragment.additional_info['property_name']
      render json: {
        'fragment_id' => @fragment.parent_id,
        'source' => source,
        'html' => render_fragment_list(
          @fragment.dmp_id,
          parent_id,
          schema.id,
          property_name,
          p_params[:template_locale],
          query_id: p_params[:query_id]
        )
      }.to_json
    else # source.eql?("select-modal")
      render json: {
        'fragment_id' => @fragment.id,
        'source' => source,
        'html' => render_fragment_select(@fragment)
      }.to_json
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  # If the fragment_id exists, load the fragment
  # else the form is opened for the first time then fragment is created
  def load_form
    if params[:id].present?
      @fragment = MadmpFragment.find(params[:id])
      authorize @fragment
    else
      p_params = permitted_params
      answer = Answer.find_by(
        research_output_id: p_params[:answer][:research_output_id],
        plan_id: p_params[:answer][:plan_id],
        question_id: p_params[:answer][:question_id]
      )
      # Checks if an answer has already been created for plan/question/research_output
      # This is needed in the case where two users open the save "new" form at the same time.
      # There was a case where two answers could be created for the question
      if answer.present?
        @fragment = answer.madmp_fragment
        authorize @fragment
      else
        schema = MadmpSchema.find(p_params[:schema_id])
        defaults = schema.defaults(p_params[:template_locale])
        classname = schema.classname
        parent_id = p_params[:parent_id] unless classname.eql?('person')
        @fragment = MadmpFragment.new(
          dmp_id: p_params[:dmp_id],
          parent_id:,
          madmp_schema: schema,
          additional_info: {
            'property_name' => p_params[:property_name]
          }
        )
        @fragment.classname = classname
        authorize @fragment

        @fragment.answer = Answer.create!(
          research_output_id: p_params[:answer][:research_output_id],
          plan_id: p_params[:answer][:plan_id],
          question_id: p_params[:answer][:question_id],
          lock_version: p_params[:answer][:lock_version],
          is_common: p_params[:answer][:is_common],
          user_id: current_user.id
        )
        @fragment.instantiate
        @fragment.handle_defaults(defaults)
      end
    end

    render json: render_fragment_form(@fragment, stale_fragment: nil)
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def update
    p_params = permitted_params
    @schemas = MadmpSchema.all
    schema = @schemas.find(p_params[:schema_id])
    source = p_params[:source]

    data = data_reformater(
      schema,
      schema_params(schema)
    )

    # rubocop:disable Metrics/BlockLength
    MadmpFragment.transaction do
      @fragment = MadmpFragment.find_by(
        id: params[:id],
        dmp_id: p_params[:dmp_id]
      )
      authorize @fragment

      if MadmpFragment.fragment_exists?(
        data, schema, p_params[:dmp_id], @fragment.parent_id, params[:id]
      )
        render json: {
          'error' => _('Element is already present in your plan.')
        }, status: 409
        return
      end

      additional_info = @fragment.additional_info.merge(
        'validations' => MadmpFragment.validate_data(data, schema.schema)
      )
      @fragment.assign_attributes(
        additional_info:,
        madmp_schema_id: schema.id
      )
      if @fragment.answer.present?
        @fragment.answer.update!(
          lock_version: p_params[:answer][:lock_version],
          is_common: p_params[:answer][:is_common],
          user_id: current_user.id
        )
      end

      @fragment.plan.touch

      @fragment.save_form_fragment(data, schema)
    rescue ActiveRecord::StaleObjectError
      @stale_fragment = @fragment
      @stale_fragment.data = @fragment.data.merge(stale_data(data, schema))

      @fragment = MadmpFragment.find_by(
        id: params[:id],
        dmp_id: p_params[:dmp_id]
      )
    end
    # rubocop:enable Metrics/BlockLength

    return unless @fragment.present?

    @fragment.update_meta_fragment

    case source
    when 'list-modal'
      property_name = @fragment.additional_info['property_name']
      render json: {
        'fragment_id' => @fragment.parent_id,
        'source' => source,
        'html' => render_fragment_list(
          @fragment.dmp_id,
          p_params[:parent_id].to_i,
          schema.id,
          property_name,
          p_params[:template_locale],
          query_id: p_params[:query_id]
        )
      }.to_json
    when 'select-modal'
      render json: {
        'fragment_id' => @fragment.id,
        'source' => source,
        'html' => render_fragment_select(@fragment)
      }.to_json
    else
      render json: render_fragment_form(@fragment, stale_fragment: @stale_fragment)
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  def change_form
    @fragment = MadmpFragment.find(params[:id])
    @schemas = MadmpSchema.all
    target_schema = @schemas.find(params[:schema_id])

    authorize @fragment

    return unless @fragment.present? && @fragment.schema_conversion(target_schema, params[:locale])

    render json: render_fragment_form(@fragment, stale_fragment: @stale_fragment)
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def new_edit_linked
    @schemas = MadmpSchema.all
    @schema = @schemas.find(params[:schema_id])

    @parent_fragment = MadmpFragment.find(params[:parent_id])
    @classname = @schema.classname
    @readonly = false
    @template_locale = params[:template_locale]
    @source = params[:source]
    @property_name = params[:property_name]
    @query_id = params[:query_id]

    dmp_id = @parent_fragment.classname == 'dmp' ? @parent_fragment.id : @parent_fragment.dmp_id
    if params[:fragment_id].present?
      @fragment = MadmpFragment.find(params[:fragment_id])
    else
      parent_id = @parent_fragment.id unless @classname.eql?('person')
      @fragment = MadmpFragment.new(
        dmp_id:,
        data: @schema.const_data(@template_locale),
        parent_id:,
        additional_info: {
          'property_name' => params[:property_name]
        }
      )
    end
    authorize @fragment
    respond_to do |format|
      format.html
      format.js { render partial: 'dynamic_form/linked_fragment' }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def show_linked
    @fragment = MadmpFragment.find(params[:fragment_id])
    @schemas = MadmpSchema.all
    @schema = @fragment.madmp_schema
    @classname = @fragment.classname
    @parent_fragment = @fragment.parent
    @readonly = true
    @template_locale = params[:template_locale]
    authorize @fragment
    respond_to do |format|
      format.html
      format.js { render partial: 'dynamic_form/linked_fragment' }
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create_from_registry_value
    parent_fragment = MadmpFragment.find(params[:parent_id])
    schema = MadmpSchema.find(params[:schema_id])
    template_locale = params[:locale]
    query_id = params[:query_id]
    readonly = params[:readonly] == 'true'
    is_custom = params[:custom_value].present?

    @fragment = MadmpFragment.new(
      dmp_id: parent_fragment.dmp_id,
      parent_id: parent_fragment.id,
      madmp_schema: schema,
      data: {},
      additional_info: {
        'property_name' => params[:property_name]
      }
    )
    @fragment.classname = schema.classname
    authorize @fragment

    if is_custom
      @fragment.additional_info = @fragment.additional_info.merge(
        'custom_value' => params[:custom_value]
      )
      @fragment.save!
    else
      @registry_value = RegistryValue.find(params[:registry_value_id])

      if MadmpFragment.fragment_exists?(
        @registry_value.data, schema, parent_fragment.dmp_id, parent_fragment.id
      )
        render json: {
          'error' => _('Element is already present in your plan.')
        }, status: 409
        return
      end

      @fragment.save_form_fragment(@registry_value.data, schema)
    end

    render json: {
      'fragment_id' => parent_fragment.id,
      'query_id' => query_id,
      'html' => render_fragment_list(
        @fragment.dmp_id,
        parent_fragment.id,
        @fragment.madmp_schema_id,
        params[:property_name],
        template_locale,
        query_id:,
        readonly:
      )
    }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def create_contributor
    parent_fragment = MadmpFragment.find(params[:parent_id])
    schema = MadmpSchema.find(params[:schema_id])
    template_locale = params[:locale]
    query_id = params[:query_id]
    person_id = params[:person_id]
    # readonly = params[:readonly] == "true"

    @contributor = MadmpFragment.new(
      dmp_id: parent_fragment.dmp_id,
      parent_id: parent_fragment.id,
      madmp_schema: schema,
      data: {
        'person' => { 'dbid' => person_id.to_i },
        'role' => params[:role]
      },
      additional_info: {
        'property_name' => params[:property_name],
        'is_multiple_contributor' => true
      }
    )
    @contributor.classname = schema.classname
    authorize @contributor
    return unless @contributor.save!

    @contributor = @contributor.becomes(Fragment::Contributor)
    render json: {
      'fragment_id' => parent_fragment.id,
      'query_id' => query_id,
      'html' => render_fragment_list(
        @contributor.dmp_id,
        parent_fragment.id,
        @contributor.person.madmp_schema_id,
        params[:property_name],
        template_locale,
        query_id:
      )
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def destroy_contributor
    @person = Fragment::Person.find(params[:contributor_id])
    contributors_list = @person.contributors
    query_id = params[:query_id]
    dmp_id = @person.dmp_id
    property_name = @person.additional_info['property_name']

    authorize @person.becomes(MadmpFragment)
    return unless @person.destroy

    # for each contributor associated to the destroyed Person fragment
    # checks if the contributor is a single (ex PrincipalInvestigator)
    # or multiple contributor (ex: DataCollector)
    contributors_list.each do |c|
      if c.additional_info['is_multiple_contributor'].present?
        c.destroy
      else
        c.update(data: c.data.merge({ 'person' => nil }))
      end
    end

    render json: {
      'fragment_id' => nil,
      'query_id' => query_id,
      'html' => render_fragment_list(
        dmp_id, nil, @person.madmp_schema_id,
        property_name, params[:template_locale], query_id:
      )
    }
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # rubocop:disable Metrics/AbcSize
  def destroy
    @fragment = MadmpFragment.find(params[:id])
    query_id = params[:query_id]
    readonly = params[:readonly] == 'true'
    parent_id = @fragment.parent_id
    dmp_id = @fragment.dmp_id
    property_name = @fragment.additional_info['property_name']

    authorize @fragment
    return unless @fragment.destroy

    MadmpFragment.find(parent_id).update_children_references if parent_id.present?
    render json: {
      'fragment_id' => parent_id,
      'query_id' => query_id,
      'html' => render_fragment_list(
        dmp_id, parent_id, @fragment.madmp_schema_id,
        property_name, params[:template_locale], query_id:, readonly:
      )
    }
  end
  # rubocop:enable Metrics/AbcSize

  private

  # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
  def render_fragment_list(dmp_id,
                           parent_id,
                           schema_id,
                           property_name,
                           template_locale,
                           query_id: nil,
                           readonly: false)
    schema = MadmpSchema.find(schema_id)
    if query_id.eql?('contributor')
      dmp = Fragment::Dmp.where(id: dmp_id).first
      @plan = dmp.plan
      render_to_string(
        partial: 'paginable/contributors/index',
        locals: {
          scope: dmp.persons
        }
      )
    elsif schema.classname.eql?('person')
      contributors = Fragment::Contributor.where(
        dmp_id:,
        parent_id:
      ).where("additional_info->>'property_name' = ?", property_name)
      # if the fragment is a Person, we consider that it's been edited from a Contributor list
      # we need to indicate that we want the contributor list to be displayed
      render_to_string(
        partial: 'dynamic_form/fields/contributor/contributor_list',
        locals: {
          contributors:,
          parent_id:,
          schema_id:,
          readonly:,
          deletable: true,
          template_locale:,
          query_id:
        }
      )
    else
      obj_list = MadmpFragment.where(
        dmp_id:,
        parent_id:
      ).where("additional_info->>'property_name' = ?", property_name)
      render_to_string(
        partial: 'dynamic_form/linked_fragment/list',
        locals: {
          parent_id:,
          obj_list:,
          schema_id:,
          readonly:,
          deletable: true,
          template_locale:,
          query_id:
        }
      )
    end
  end
  # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

  def render_fragment_select(fragment)
    select_values = MadmpFragment.where(
      dmp_id: fragment.dmp_id,
      madmp_schema_id: fragment.madmp_schema_id
    )
    render_to_string(
      partial: 'dynamic_form/linked_fragment/select_options',
      locals: {
        selected_value: fragment.id,
        select_values:
      }
    )
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def render_fragment_form(fragment, stale_fragment: nil)
    answer = fragment.answer
    question = answer&.question
    research_output = answer&.research_output
    section = question&.section
    plan = fragment.plan
    template = plan.template
    madmp_schema = fragment.madmp_schema
    run_parameters = madmp_schema.extract_run_parameters
    editable = plan.editable_by?(current_user.id)

    {
      'fragment_id' => fragment.id,
      'answer' => {
        'id' => answer&.id
      },
      qn_data: { to_hide: [], to_show: [] },
      section_data: [],
      'question' => {
        'id' => question&.id,
        'answer_lock_version' => answer&.lock_version,
        'locking' => if stale_fragment
                       render_to_string(partial: 'madmp_fragments/locking', locals:
                       {
                         fragment: stale_fragment,
                         template_locale: LocaleService.to_gettext(locale: template.locale),
                         user: answer&.user
                       }, formats: [:html])
                     end,
        'form' => render_to_string(partial: 'madmp_fragments/edit', locals:
        {
          template:,
          question:,
          answer:,
          fragment:,
          madmp_schema:,
          research_output:,
          dmp_id: fragment.dmp_id,
          parent_id: fragment.parent_id,
          pickable_schemas: MadmpSchema.where(classname: fragment.classname).order(:label),
          readonly: !editable,
          base_template_org: template.base_org
        }, formats: [:html]),
        'form_run' => if madmp_schema.run_parameters?
                        render_to_string(partial: 'dynamic_form/codebase/show', locals:
                        {
                          fragment:,
                          api_client: madmp_schema.api_client,
                          parameters: run_parameters,
                          template_locale: LocaleService.to_gettext(locale: template.locale)
                        }, formats: [:html])
                      end,
        'answer_status' => if answer.present?
                             render_to_string(partial: 'answers/status', locals:
                             {
                               answer:
                             }, formats: [:html])
                           end
      },
      'section' => {
        'id' => section&.id
      },
      'plan' => {
        'id' => plan.id,
        'title' => plan.title,
        'progress' => if section.present?
                        render_to_string(partial: 'plans/progress', locals:
                        {
                          plan:,
                          current_phase: section.phase
                        }, formats: [:html])
                      end
      },
      'research_output' => {
        'id' => research_output&.id
      }
    }.to_json
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

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
