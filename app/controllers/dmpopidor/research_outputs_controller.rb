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

    # rubocop:disable Metrics/AbcSize
    def destroy
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

    def sort
      @plan = ::Plan.find(params[:plan_id])
      authorize @plan
      params[:updated_order].each_with_index do |id, index|
        ::ResearchOutput.find(id).update(display_order: index + 1)
      end
      head :ok
    end

    def create_remote
      @plan = ::Plan.find(params[:plan_id])
      max_order = @plan.research_outputs.maximum('display_order') + 1
      @plan.research_outputs.create(
        abbreviation: "Research Output #{max_order}",
        title: "New research output #{max_order}",
        is_default: false,
        display_order: max_order
      )

      authorize @plan
      render json: {
        'html' => render_to_string(partial: 'research_outputs/list', locals: {
                                     plan: @plan,
                                     research_outputs: @plan.research_outputs,
                                     readonly: false
                                   })
      }
    end

    def research_output_params
      params.require(:research_output)
            .permit(:id, :plan_id, :abbreviation, :title, :pid, :output_type_description, :contact_id)
    end
  end
end
