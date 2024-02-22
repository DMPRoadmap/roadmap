# frozen_string_literal: true

module Dmpopidor
  # Customized code for ResearchOutputsController
  module ResearchOutputsController
    include Dmpopidor::ErrorHelper
    # GET /plans/:plan_id/research_outputs
    def index
      @plan = ::Plan.find(params[:plan_id])
      @research_outputs = @plan.research_outputs
      @persons = @plan.json_fragment.persons
      authorize @plan
      render('plans/research_outputs', locals: { plan: @plan, research_outputs: @research_outputs })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = format(_('There is no plan associated with id %{id}'), id: params[:id])
      redirect_to(controller: 'plans', action: 'index')
    end

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def create
      authorize @plan
      I18n.with_locale @plan.template.locale do
        begin
          max_order = @plan.research_outputs.maximum('display_order') + 1
          created_ro = @plan.research_outputs.create!(
            abbreviation: params[:abbreviation] || "#{_('RO')} #{max_order}",
            title: params[:title] || "#{_('Research output')} #{max_order}",
            output_type_description: params[:type],
            is_default: false,
            display_order: max_order
          )
          created_ro.create_json_fragments(params[:configuration])

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
                type: ro.json_fragment.research_output_description['data']['type'],
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
        rescue ActiveRecord::RecordInvalid  => e
          Rails.logger.error(e.backtrace.join("\n"))
          internal_server_error(e.message)
        end
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    def update
      @research_output = ::ResearchOutput.find(params[:id])
      plan =  @research_output.plan
      attrs = research_output_params

      authorize @research_output

      I18n.with_locale plan.template.locale do
        begin
          research_output_description = @research_output.json_fragment.research_output_description

            updated_data = research_output_description.data.merge({
              title: params[:title],
              type: params[:type],
              containsPersonalData: params[:configuration][:hasPersonalData] ? _('Yes') : _('No')
            })
            research_output_description.update(data: updated_data)
            research_output_description.update_research_output_parameters(true)
            PlanChannel.broadcast_to(plan, {
              target: "dynamic_form",
              fragment_id: research_output_description.id,
              payload: research_output_description.get_full_fragment(with_ids: true)
            })

          research_outputs = ::ResearchOutput.where(plan_id: params[:plan_id])

          @research_output.update!(attrs)

          render json: {
            status: 200,
            message: 'Research output updated',
            research_outputs: research_outputs.order(:display_order).map do |ro|
              {
                id: ro.id,
                abbreviation: ro.abbreviation,
                title: ro.title,
                order: ro.display_order,
                hasPersonalData: ro.has_personal_data,
                type: ro.json_fragment.research_output_description['data']['type'],
                answers: ro.answers.map do |a|
                  {
                    answer_id: a.id,
                    question_id: a.question_id,
                    fragment_id: a.madmp_fragment.id
                  }
                end
              }
            end
          },
          status: :ok
        rescue ActiveRecord::RecordInvalid  => e
          Rails.logger.error(e.backtrace.join("\n"))
          internal_server_error(e.message)
        end
      end
    end

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
      @persons = @plan.json_fragment.persons
      max_order = @plan.research_outputs.maximum('display_order') + 1
      created_ro = @plan.research_outputs.create(
        abbreviation: "RO #{max_order}",
        title: "Research output #{max_order}",
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
      p "##################################################"
      p @research_output
      p "##################################################"
      @persons = @plan.json_fragment.persons
      authorize @plan
      if @research_output.destroy
        flash[:notice] = success_message(@research_output, _('deleted'))
      else
        flash[:alert] = failure_message(@research_output, _('delete'))
      end
      redirect_to(action: 'index', plan_id: @plan.id)
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    def update_remote
      @plan = ::Plan.find(params[:plan_id])
      @research_output = ::ResearchOutput.find(params[:id])
      @persons = @plan.json_fragment.persons
      attrs = research_output_params
      contact_id = params[:contact_id]

      authorize @plan
      if @research_output.update(attrs)
        @research_output.create_json_fragments
        research_output_description = @research_output.json_fragment.research_output_description
        research_output_description.instantiate
        research_output_description.contact.update(
          data: {
            'person' => contact_id.present? ? { 'dbid' => contact_id } : nil,
            'role' => _('Data contact')
          }
        )
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
