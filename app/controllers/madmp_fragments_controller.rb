# frozen_string_literal: true

class MadmpFragmentsController < ApplicationController

  after_action :verify_authorized
  include DynamicFormHelper

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

    if source == "form"
      @fragment.answer = Answer.create!(
        {
          research_output_id: p_params[:answer][:research_output_id],
          plan_id: p_params[:answer][:plan_id],
          question_id: p_params[:answer][:question_id],
          lock_version: p_params[:answer][:lock_version],
          is_common: p_params[:answer][:is_common],
          user_id: current_user.id
        }
      )
      @fragment.instantiate
    else
      data = data_reformater(
        schema.schema,
        schema_params(schema)
      )
      additional_info = @fragment.additional_info.merge(
        {
          "validations" => MadmpFragment.validate_data(data, schema.schema)
        }
      )
      @fragment.assign_attributes(
        additional_info: additional_info
      )
      @fragment.instantiate
      @fragment.save_as_multifrag(data, schema)
    end

    return unless @fragment.present?

    if @fragment.answer.present?
      render json: render_fragment_form(@fragment, @stale_fragment)
    elsif source.eql?("list-modal")
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
    else
      render json: {
        "fragment_id" =>  parent_id,
        "source" => source,
        "html" => render_fragment_select(@fragment)
      }.to_json
    end
  end

  def load_form
    @fragment = MadmpFragment.find_by(id: params[:id])
    @schemas = MadmpSchema.all
    authorize @fragment

    return unless @fragment.present?

    render json: render_fragment_form(@fragment, @stale_fragment)
  end

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
        # data = @fragment.data.merge(data)
        additional_info = @fragment.additional_info.merge(
          {
            "validations" => MadmpFragment.validate_data(data, schema.schema)
          }
        )
        @fragment.assign_attributes(
          # data: data,
          additional_info: additional_info,
          madmp_schema_id: schema.id
        )

        authorize @fragment
        if p_params[:source] == "form"
          @fragment.answer.update!(
            {
              lock_version: p_params[:answer][:lock_version],
              is_common: p_params[:answer][:is_common],
              user_id: current_user.id
            }
          )
        end
        # @fragment.save!
        @fragment.save_as_multifrag(data, schema)
      rescue ActiveRecord::StaleObjectError
        @stale_fragment = @fragment
        @fragment = MadmpFragment.find_by(
          {
            id: params[:id],
            dmp_id: p_params[:dmp_id]
          }
        )
      end
      # rubocop:enable Metrics/BlockLength
    end

    return unless @fragment.present?

    if @fragment.answer.present?
      render json: render_fragment_form(@fragment, @stale_fragment)
    elsif source.eql?("list-modal")
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
    else
      render json: {
        "fragment_id" =>  @fragment.parent_id,
        "source" => source,
        "html" => render_fragment_select(@fragment)
      }.to_json
    end
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
    if params[:fragment_id]
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

  def create_from_registry_value
    parent_fragment = MadmpFragment.find(params[:parent_id])
    schema = MadmpSchema.find(params[:schema_id])
    template_locale = params[:locale]
    query_id = params[:query_id]
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
      @fragment.save_as_multifrag(@registry_value.data, schema)
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
        true
      )
    }
  end

  def destroy
    @fragment = MadmpFragment.find(params[:id])
    query_id = params[:query_id]
    readonly = params[:readonly]
    parent_id = @fragment.parent_id
    dmp_id = @fragment.dmp_id
    property_name = @fragment.additional_info["property_name"]

    authorize @fragment
    return unless @fragment.destroy

    render json: {
      "fragment_id" =>  parent_id,
      "query_id" => query_id,
      "html" => render_fragment_list(
        dmp_id, parent_id, @fragment.madmp_schema_id, property_name, nil, query_id, readonly
      )
    }
  end

  # Gets fragment from a given id
  def get_fragment
    @fragment = MadmpFragment.find(params[:id])
    authorize @fragment

    return unless @fragment.present?

    render json: @fragment.data
  end

  private

  def render_fragment_list(dmp_id, parent_id, schema_id, property_name, template_locale, query_id = nil, readonly = false)
    schema = MadmpSchema.find(schema_id)
    case schema.classname
    when "research_output"
      @plan = Fragment::Dmp.where(id: dmp_id).first.plan
      render_to_string(
        partial: "research_outputs/list",
        locals: {
          plan: @plan,
          research_outputs: @plan.research_outputs,
          readonly: readonly
        }
      )
    else
      obj_list = MadmpFragment.where(
        dmp_id: dmp_id,
        parent_id: parent_id,
        madmp_schema_id: schema_id
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
    question = answer.question
    research_output = answer.research_output
    section = question.section
    plan = answer.plan
    template = section.phase.template

    return {
            "answer" => {
              "id" => answer.id
            },
            "question" => {
              "id" => question.id,
              "answer_lock_version" => answer.lock_version,
              "locking" => stale_fragment ?
                render_to_string(partial: "madmp_fragments/locking", locals: {
                  question: question,
                  answer: answer,
                  fragment: stale_fragment,
                  research_output: research_output,
                  user: answer.user
                }, formats: [:html]) :
                nil,
              "form" => render_to_string(partial: "madmp_fragments/edit", locals: {
                template: template,
                question: question,
                answer: answer,
                fragment: fragment ,
                madmp_schema: fragment.madmp_schema,
                research_output: research_output,
                dmp_id: fragment.dmp_id,
                parent_id: fragment.parent_id,
                readonly: false,
                base_template_org: template.base_org
              }, formats: [:html]),
              "answer_status" => render_to_string(partial: "answers/status", locals: {
                answer: answer
              }, formats: [:html])
            },
            "section" => {
              "id" => section.id,
              "progress" => render_to_string(partial: "/org_admin/sections/progress", locals: {
                section: section,
                plan: plan
              }, formats: [:html])
            },
            "plan" => {
              "id" => plan.id,
              "progress" => render_to_string(partial: "plans/progress", locals: {
                plan: plan,
                current_phase: section.phase
              }, formats: [:html])
            },
            "research_output" => {
              "id" => research_output.id
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
