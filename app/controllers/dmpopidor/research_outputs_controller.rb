# frozen_string_literal: true

module Dmpopidor
  # Customized code for ResearchOutputsController
  module ResearchOutputsController
    # GET /plans/:plan_id/research_outputs
    def index
      @plan = ::Plan.find(params[:plan_id])
      @research_outputs = @plan.research_outputs
      authorize @plan
      render('plans/research_outputs', locals: { plan: @plan, research_outputs: @research_outputs })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = format(_('There is no plan associated with id %{id}'), id: params[:id])
      redirect_to(controller: 'plans', action: 'index')
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def create
      max_order = @plan.research_outputs.maximum('display_order') + 1
      created_ro = @plan.research_outputs.create(
        abbreviation: params[:abbreviation] || "Research Output #{max_order}",
        title: params[:title] || "New research output #{max_order}",
        output_type_description: params[:type],
        is_default: false,
        display_order: max_order
      )
      created_ro.create_json_fragments(params[:research_output_parameters])
      authorize @plan

      render json: {
        id: @plan.id,
        created_ro_id: created_ro.id,
        dmp_id: @plan.json_fragment.id,
        research_outputs: @plan.research_outputs.order(:display_order).map do |ro|
          {
            id: ro.id,
            abbreviation: ro.abbreviation,
            title: ro.title,
            order: ro.display_order,
            hasPersonalData: ro.has_personal_data,
            answers: ro.answers.map do |a|
              {
                answer_id: a.id,
                question_id: a.question_id,
                fragment_id: a.madmp_fragment.id
              }
            end
          }
        end
      }
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def destroy
      @research_output = ::ResearchOutput.find(params[:id])
      research_output_fragment = @research_output.json_fragment
      authorize @plan
      if @research_output.destroy
        research_output_fragment.destroy!
        render json: {
          id: @plan.id,
          dmp_id: @plan.json_fragment.id,
          research_outputs: @plan.research_outputs.order(:display_order).map do |ro|
            {
              id: ro.id,
              abbreviation: ro.abbreviation,
              title: ro.title,
              order: ro.display_order,
              hasPersonalData: ro.has_personal_data,
              answers: ro.answers.map do |a|
                {
                  answer_id: a.id,
                  question_id: a.question_id,
                  fragment_id: a.madmp_fragment.id
                }
              end
            }
          end
        }
      else        
        render json: {
          'error' => failure_message(@research_output, _('delete'))
        }, status: 500
      end
    end
    # rubocop:enable Metrics/AbcSize

    # DELETE AFTER V4 ?

    def create_remote
      @plan = ::Plan.find(params[:plan_id])
      max_order = @plan.research_outputs.maximum('display_order') + 1
      created_ro = @plan.research_outputs.create(
        abbreviation: "Research Output #{max_order}",
        title: "New research output #{max_order}",
        is_default: false,
        display_order: max_order
      )
      created_ro.create_json_fragments

      authorize @plan
      render json: {
        'html' => render_to_string(partial: 'research_outputs/list', locals: {
                                     plan: @plan,
                                     research_outputs: @plan.research_outputs,
                                     readonly: false
                                   })
      }
    end
    
    # rubocop:disable Metrics/AbcSize
    def destroy_remote
      @plan = ::Plan.find(params[:plan_id])
      @research_output = ::ResearchOutput.find(params[:id])
      research_output_fragment = @research_output.json_fragment
      authorize @plan
      if @research_output.destroy
        research_output_fragment.destroy!
        flash[:notice] = success_message(@research_output, _('deleted'))
      else
        flash[:alert] = failure_message(@research_output, _('delete'))
      end
      redirect_to(action: 'index')
    end
    # rubocop:enable Metrics/AbcSize
    

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def update
      @plan = ::Plan.find(params[:plan_id])
      @research_output = ::ResearchOutput.find(params[:id])
      attrs = research_output_params
      contact_id = params[:contact_id]

      authorize @plan
      if @research_output.update(attrs)
        @research_output.create_json_fragments
        unless @plan.template.structured?
          research_output_description = @research_output.json_fragment.research_output_description
          research_output_description.contact.update(
            data: {
              'person' => contact_id.present? ? { 'dbid' => contact_id } : nil,
              'role' => _('Data contact')
            }
          )
        end
        render json: {
          'html' => render_to_string(partial: 'research_outputs/list', locals:
            {
              plan: @plan,
              research_outputs: @plan.research_outputs,
              readonly: false
            })
        }
      else
        flash[:alert] = failure_message(@research_output, _('update'))
        redirect_to(action: 'index')
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    def sort
      @plan = ::Plan.find(params[:plan_id])
      authorize @plan
      params[:updated_order].each_with_index do |id, index|
        ::ResearchOutput.find(id).update(display_order: index + 1)
      end
      head :ok
    end

    def research_output_params
      params.require(:research_output)
            .permit(:id, :plan_id, :abbreviation, :title, :pid, :output_type_description, :contact_id)
    end
  end
end
