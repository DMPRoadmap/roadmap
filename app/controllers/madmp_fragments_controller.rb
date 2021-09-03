# frozen_string_literal: true

class MadmpFragmentsController < ApplicationController

  after_action :verify_authorized
  include DynamicFormHelper

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  def create
    p_params = permitted_params
    @schemas = MadmpSchema.all
    schema = @schemas.find(p_params[:schema_id])
    source = p_params[:source]
    classname = schema.classname
    parent_id = p_params[:parent_id] unless classname.eql?("person")

    @fragment = MadmpFragment.new(
      dmp_id: p_params[:dmp_id],
      parent_id: parent_id,
      madmp_schema: schema,
      additional_info: {
        "property_name" => p_params[:property_name]
      }
    )
    @fragment.classname = classname

    authorize @fragment

    if source.eql?("form")
      @fragment.answer = Answer.create!(
        research_output_id: p_params[:answer][:research_output_id],
        plan_id: p_params[:answer][:plan_id],
        question_id: p_params[:answer][:question_id],
        lock_version: p_params[:answer][:lock_version],
        is_common: p_params[:answer][:is_common],
        user_id: current_user.id
      )
      @fragment.instantiate
    else
      data = data_reformater(
        schema.schema,
        schema_params(schema)
      )
      if MadmpFragment.fragment_exists?(data, schema, p_params[:dmp_id], parent_id)
        render json: {
          "error" => d_("dmpopidor", "Element is already present in your plan.")
        }, status: 409
        return
      end

      additional_info = @fragment.additional_info.merge(
        "validations" => MadmpFragment.validate_data(data, schema.schema)
      )
      @fragment.assign_attributes(
        additional_info: additional_info
      )
      @fragment.instantiate
      @fragment.save_form_fragment(data, schema)
    end

    return unless @fragment.present?

    if source.eql?("list-modal")
      property_name = @fragment.additional_info["property_name"]
      render json: {
        "fragment_id" =>  @fragment.parent_id,
        "source" => source,
        "html" => render_fragment_list(
          @fragment.dmp_id,
          parent_id,
          schema.id,
          property_name,
          p_params[:template_locale],
          p_params[:query_id]
        )
      }.to_json
    elsif source.eql?("select-modal")
      render json: {
        "fragment_id" =>  @fragment.id,
        "source" => source,
        "html" => render_fragment_select(@fragment)
      }.to_json
    else
      render json: render_fragment_form(@fragment, @stale_fragment)
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def load_form
    @fragment = MadmpFragment.find(params[:id])
    @schemas = MadmpSchema.all
    authorize @fragment

    return unless @fragment.present?
    @fragment.instantiate
    render json: render_fragment_form(@fragment, @stale_fragment)
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def update
    p_params = permitted_params
    @schemas = MadmpSchema.all
    schema = @schemas.find(p_params[:schema_id])
    source = p_params[:source]

    data = data_reformater(
      schema.schema,
      schema_params(schema)
    )

    # rubocop:disable Metrics/BlockLength
    Answer.transaction do
      begin
        @fragment = MadmpFragment.find_by(
          id: params[:id],
          dmp_id: p_params[:dmp_id]
        )
        authorize @fragment

        if MadmpFragment.fragment_exists?(
          data, schema, p_params[:dmp_id], @fragment.parent_id, params[:id]
        )
          render json: {
            "error" => d_("dmpopidor", "Element is already present in your plan.")
          }, status: 409
          return
        end

        # data = @fragment.data.merge(data)
        additional_info = @fragment.additional_info.merge(
          "validations" => MadmpFragment.validate_data(data, schema.schema)
        )
        @fragment.assign_attributes(
          # data: data,
          additional_info: additional_info,
          madmp_schema_id: schema.id
        )
        if p_params[:source].eql?("form") && @fragment.answer.present?
          @fragment.answer.update!(
            lock_version: p_params[:answer][:lock_version],
            is_common: p_params[:answer][:is_common],
            user_id: current_user.id
          )
        end
        # @fragment.save!
        @fragment.save_form_fragment(data, schema)
      rescue ActiveRecord::StaleObjectError
        @stale_fragment = @fragment
        @fragment = MadmpFragment.find_by(
          id: params[:id],
          dmp_id: p_params[:dmp_id]
        )
      end
      # rubocop:enable Metrics/BlockLength
    end

    return unless @fragment.present?

    if source.eql?("list-modal")
      property_name = @fragment.additional_info["property_name"]
      render json: {
        "fragment_id" =>  @fragment.parent_id,
        "source" => source,
        "html" => render_fragment_list(
          @fragment.dmp_id,
          @fragment.parent_id,
          schema.id,
          property_name,
          p_params[:template_locale],
          p_params[:query_id]
        )
      }.to_json
    elsif source.eql?("select-modal")
      render json: {
        "fragment_id" =>  @fragment.id,
        "source" => source,
        "html" => render_fragment_select(@fragment)
      }.to_json
    else
      render json: render_fragment_form(@fragment, @stale_fragment)
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def change_schema
    @fragment = MadmpFragment.find(params[:id])
    @schemas = MadmpSchema.all
    target_schema = @schemas.find(params[:schema_id])

    authorize @fragment

    return unless @fragment.present? && @fragment.schema_conversion(target_schema)

    render json: render_fragment_form(@fragment, @stale_fragment)
  end

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

    dmp_id = @parent_fragment.classname == "dmp" ? @parent_fragment.id : @parent_fragment.dmp_id
    if params[:fragment_id].present?
      @fragment = MadmpFragment.find(params[:fragment_id])
    else
      parent_id = @parent_fragment.id unless @classname.eql?("person")
      @fragment = MadmpFragment.new(
        dmp_id: dmp_id,
        parent_id: parent_id,
        additional_info: {
          "property_name" => params[:property_name]
        }
      )
    end
    authorize @fragment
    respond_to do |format|
      format.html
      format.js { render partial: "shared/dynamic_form/linked_fragment" }
    end
  end

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
      format.js { render partial: "shared/dynamic_form/linked_fragment" }
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def create_from_registry_value
    parent_fragment = MadmpFragment.find(params[:parent_id])
    schema = MadmpSchema.find(params[:schema_id])
    template_locale = params[:locale]
    query_id = params[:query_id]
    readonly = params[:readonly] == "true"
    is_custom = params[:custom_value].present? ? true : false

    @fragment = MadmpFragment.new(
      dmp_id: parent_fragment.dmp_id,
      parent_id: parent_fragment.id,
      madmp_schema: schema,
      data: {},
      additional_info: {
        "property_name" => params[:property_name]
      }
    )
    @fragment.classname = schema.classname
    authorize @fragment

    if is_custom
      @fragment.additional_info = @fragment.additional_info.merge("custom_value" => params[:custom_value])
      @fragment.save!
    else
      @registry_value = RegistryValue.find(params[:registry_value_id])

      if MadmpFragment.fragment_exists?(
        @registry_value.data, schema, parent_fragment.dmp_id, parent_fragment.id
      )
        render json: {
          "error" => d_("dmpopidor", "Element is already present in your plan.")
        }, status: 409
        return
      end

      @fragment.save_form_fragment(@registry_value.data, schema)
    end

    render json: {
      "fragment_id" =>  parent_fragment.id,
      "query_id" => query_id,
      "html" => render_fragment_list(
        @fragment.dmp_id,
        parent_fragment.id,
        @fragment.madmp_schema_id,
        params[:property_name],
        template_locale,
        query_id,
        readonly
      )
    }
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

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
        "person" => { "dbid" => person_id.to_i },
        "role" => params[:role]
      },
      additional_info: {
        "property_name" => params[:property_name]
      }
    )
    @contributor.classname = schema.classname
    authorize @contributor
    return unless @contributor.save!

    render json: {
      "fragment_id" =>  parent_fragment.id,
      "query_id" => query_id,
      "html" => render_fragment_list(
        @contributor.dmp_id,
        parent_fragment.id,
        @contributor.madmp_schema_id,
        params[:property_name],
        template_locale,
        query_id,
        true
      )
    }
  end

  def destroy
    @fragment = MadmpFragment.find(params[:id])
    query_id = params[:query_id]
    readonly = params[:readonly] == "true"
    parent_id = @fragment.parent_id
    dmp_id = @fragment.dmp_id
    property_name = @fragment.additional_info["property_name"]

    authorize @fragment
    return unless @fragment.destroy

    MadmpFragment.find(parent_id).update_children_references if parent_id.present?
    render json: {
      "fragment_id" =>  parent_id,
      "query_id" => query_id,
      "html" => render_fragment_list(
        dmp_id, parent_id, @fragment.madmp_schema_id,
        property_name, params[:template_locale], query_id, readonly
      )
    }
  end

  def load_fragments
    @dmp_fragment = MadmpFragment.find(params[:dmp_id])
    search_term = params[:term] || ""
    fragment_list = MadmpFragment.where(
      dmp_id: @dmp_fragment.id,
      madmp_schema_id: params[:schema_id]
    )
    formatted_list = fragment_list.select { |f| f.to_s.downcase.include?(search_term) }
                                  .map    { |f| { "id" => f.id, "text" => f.to_s } }
    authorize @dmp_fragment
    render json: {
      "results" => formatted_list
    }
  end

  private

  def render_fragment_list(dmp_id, parent_id, schema_id, property_name, template_locale, query_id = nil, readonly = false)
    schema = MadmpSchema.find(schema_id)
    case schema.classname
    when "person"
      dmp = Fragment::Dmp.where(id: dmp_id).first
      @plan = dmp.plan
      render_to_string(
        partial: "paginable/contributors/index",
        locals: {
          scope: dmp.persons
        }
      )
    else
      obj_list = MadmpFragment.where(
        dmp_id: dmp_id,
        parent_id: parent_id
      ).where("additional_info->>'property_name' = ?", property_name)
      render_to_string(
        partial: "shared/dynamic_form/linked_fragment/list",
        locals: {
          parent_id: parent_id,
          obj_list: obj_list,
          schema_id: schema_id,
          readonly: readonly,
          deletable: true,
          template_locale: template_locale,
          query_id: query_id
        }
      )
    end
  end

  def render_fragment_select(fragment)
    select_values = MadmpFragment.where(
      dmp_id: fragment.dmp_id,
      madmp_schema_id: fragment.madmp_schema_id
    )
    render_to_string(
      partial: "shared/dynamic_form/linked_fragment/select_options",
      locals: {
        selected_value: fragment.id,
        select_values: select_values
      }
    )
  end

  def render_fragment_form(fragment, stale_fragment = nil)
    answer = fragment.answer
    question = answer&.question
    research_output = answer&.research_output
    section = question&.section
    plan = fragment.plan
    template = plan.template
    run_parameters = fragment.madmp_schema.extract_run_parameters
    editable = plan.editable_by?(current_user)

    {
      "fragment_id" => fragment.id,
      "answer" => {
        "id" => answer&.id
      },
      "qn_data": { to_hide: [], to_show: [] },
      "section_data": [],
      "question" => {
        "id" => question&.id,
        "answer_lock_version" => answer&.lock_version,
        "locking" => stale_fragment ?
          render_to_string(partial: "madmp_fragments/locking", locals: {
            question: question,
            answer: answer,
            fragment: stale_fragment,
            research_output: research_output,
            user: answer&.user
          }, formats: [:html]) :
          nil,
        "form" => render_to_string(partial: "madmp_fragments/edit", locals: {
          template: template,
          question: question,
          answer: answer,
          fragment: fragment,
          madmp_schema: fragment.madmp_schema,
          research_output: research_output,
          dmp_id: fragment.dmp_id,
          parent_id: fragment.parent_id,
          pickable_schemas: MadmpSchema.where(classname: fragment.classname).order(:label),
          readonly: !editable,
          base_template_org: template.base_org
        }, formats: [:html]),
        "form_run" => run_parameters.present? ? 
          render_to_string(partial: "shared/dynamic_form/codebase/show", locals: {
            fragment: fragment,
            parameters: run_parameters,
            template_locale: template.locale
          }, formats: [:html]) : nil,
        "answer_status" => answer.present? ?
          render_to_string(partial: "answers/status", locals: {
            answer: answer
        }, formats: [:html]) :
        nil
      },
      "section" => {
        "id" => section&.id
      },
      "plan" => {
        "id" => plan.id,
        "progress" => section.present? ?
          render_to_string(partial: "plans/progress", locals: {
            plan: plan,
            current_phase: section.phase
        }, formats: [:html]) :
        nil
      },
      "research_output" => {
        "id" => research_output&.id
      }
    }.to_json
  end

  # Get the parameters conresponding to the schema
  def schema_params(schema, flat = false)
    s_params = schema.generate_strong_params(flat)
    params.require(:madmp_fragment).permit(s_params)
  end

  def permitted_params
    permit_arr = [:id, :dmp_id, :parent_id, :schema_id, :source, :template_locale,
                  :property_name, :query_id, answer: %i[id plan_id research_output_id
                             question_id lock_version is_common]
                ]
    params.require(:madmp_fragment).permit(permit_arr)
  end

end
