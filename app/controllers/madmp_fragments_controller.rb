# frozen_string_literal: true

class MadmpFragmentsController < ApplicationController

  after_action :verify_authorized
  include DynamicFormHelper

  def create_or_update
    p_params = permitted_params
    @schemas = MadmpSchema.all
    schema = @schemas.find(p_params[:schema_id])

    classname = schema.classname
    data = data_reformater(schema.schema, schema_params(schema), schema.classname)
    @fragment = nil

    if params[:id].present?
      # rubocop:disable Metrics/BlockLength
      Answer.transaction do
        begin
          @fragment = MadmpFragment.find_by(
            id: params[:id],
            dmp_id: p_params[:dmp_id],
          )
          # data = @fragment.data.merge(data)
          additional_info = {
            "validations" => MadmpFragment.validate_data(data, schema.schema)
          }
          @fragment.assign_attributes(
            # data: data, 
            additional_info: additional_info,
            madmp_schema_id: schema.id
          )

          authorize @fragment
          unless p_params[:source] == "modal"
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
      end
      # rubocop:enable Metrics/BlockLength
    else
      @fragment = MadmpFragment.new(
        dmp_id: p_params[:dmp_id],
        parent_id: p_params[:parent_id],
        madmp_schema: schema
      )
      @fragment.classname = classname
      additional_info = { 
        "validations" => MadmpFragment.validate_data(data, schema.schema)
      }
      @fragment.assign_attributes(
        # data: data,
        additional_info: additional_info
      )

      unless p_params[:source] == "modal"
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
      end
      authorize @fragment
      # @fragment.save!
      @fragment.save_as_multifrag(data, schema)
    end

    return unless @fragment.present?

    if @fragment.answer.present?
      render json: render_fragment_form(@fragment, @stale_fragment)
    else
      render json: {
        "fragment_id" =>  @fragment.parent_id,
        "classname" => classname,
        "html" => render_fragment_list(
          @fragment.dmp_id,
          @fragment.parent_id,
          schema.id,
          p_params[:template_locale]
        )
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

    @fragment = nil
    dmp_id = @parent_fragment.classname == "dmp" ? @parent_fragment.id : @parent_fragment.dmp_id
    if params[:fragment_id]
      @fragment = MadmpFragment.find(params[:fragment_id])
    else
      @fragment = MadmpFragment.new(
        dmp_id: dmp_id,
        parent_id: @parent_fragment.id
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

  def destroy 
    @fragment = MadmpFragment.find(params[:id])
    classname = @fragment.classname
    parent_id = @fragment.parent_id
    dmp_id = @fragment.dmp_id

    authorize @fragment
    render json: {
      "fragment_id" =>  parent_id,
      "classname" => classname,
      "html" => render_fragment_list(dmp_id, parent_id, @fragment.madmp_schema_id, nil)
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

  def render_fragment_list(dmp_id, parent_id, schema_id, template_locale)
    schema = MadmpSchema.find(schema_id)
    case schema.classname
    when "research_output"
      @plan = Fragment::Dmp.where(id: dmp_id).first.plan
      render_to_string(
        partial: "research_outputs/list",
        locals: {
          plan: @plan,
          research_outputs: @plan.research_outputs,
          readonly: false
        }
      )

    else
      obj_list = MadmpFragment.where(
        dmp_id: dmp_id,
        parent_id: parent_id,
        madmp_schema_id: schema.id
      )
      render_to_string(
        partial: "shared/dynamic_form/linked_fragment/list",
        locals: {
          parent_id: parent_id,
          obj_list: obj_list,
          schema: schema,
          readonly: false,
          template_locale: template_locale
        }
      )
    end
  end

  def render_fragment_form(fragment, stale_fragment = nil)
    answer = fragment.answer
    question = answer.question
    research_output = answer.research_output
    section = question.section
    plan = answer.plan

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
              "form" => render_to_string(partial: "madmp_fragments/new_edit", locals: {
                question: question,
                answer: answer,
                fragment: fragment ,
                madmp_schema: fragment.madmp_schema,
                research_output: research_output,
                dmp_id: fragment.dmp_id,
                parent_id: fragment.parent_id,
                readonly: false
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
                  answer: %i[id plan_id research_output_id
                             question_id lock_version is_common]
                ]
    params.require(:madmp_fragment).permit(permit_arr)
  end

end
