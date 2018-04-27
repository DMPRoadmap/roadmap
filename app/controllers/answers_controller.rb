class AnswersController < ApplicationController
  respond_to :html

	# POST /answers/create_or_update
  def create_or_update
    p_params = permitted_params()

    #First it is checked plan exists and question exist for that plan
    begin
      p = Plan.find(p_params[:plan_id])
      if !p.question_exists?(p_params[:question_id])
        render(status: :not_found, json:
        { msg: _("There is no question with id %{question_id} associated to plan id %{plan_id}"\
          "for which to create or update an answer") %{ :question_id => p_params[:question_id], :plan_id => p_params[:plan_id] }})
        return
      end
    rescue ActiveRecord::RecordNotFound
      render(status: :not_found, json:
        { msg: _('There is no plan with id %{id} for which to create or update an answer') %{ :id => p_params[:plan_id] }})
      return
    end
    q = Question.find(p_params[:question_id])

    Answer.transaction do
      begin
        @answer = Answer.find_by!({ plan_id: p_params[:plan_id], question_id: p_params[:question_id] })
        authorize @answer
        @answer.update(p_params.merge({ user_id: current_user.id }))
        if p_params[:question_option_ids].present?
          @answer.touch() # Saves the record with the updated_at set to the current time. Needed if only answer.question_options is updated
        end
        if q.question_format.rda_metadata?
          @answer.update_answer_hash(JSON.parse(params[:standards]), p_params[:text])
          @answer.save!
        end
      rescue ActiveRecord::RecordNotFound
        @answer = Answer.new(p_params.merge({ user_id: current_user.id }))
        @answer.lock_version = 1
        authorize @answer
        if q.question_format.rda_metadata?
          @answer.update_answer_hash(JSON.parse(params[:standards]), p_params[:text])
        end
        @answer.save!
      rescue ActiveRecord::StaleObjectError
        @stale_answer = @answer
        @answer = Answer.find_by({plan_id: p_params[:plan_id], question_id: p_params[:question_id]})
      end
    end

    if @answer.present?
      @plan = Plan.includes({
        sections: {
          questions: [
            :answers,
            :question_format
          ]
        }
      }).find(p_params[:plan_id])
      @question = @answer.question
      @section = @plan.get_section(@question.section_id)
      template = @section.phase.template

      render json: {
        "question" => {
          "id" => @question.id,
          "answer_lock_version" => @answer.lock_version,
          "locking" => @stale_answer ?
            render_to_string(partial: 'answers/locking', locals: { question: @question, answer: @stale_answer, user: @answer.user }, formats: [:html]) :
            nil,
          "form" => render_to_string(partial: 'answers/new_edit', locals: { template: template, question: @question, answer: @answer, readonly: false, locking: false, base_template_org: template.base_org }, formats: [:html]),
          "answer_status" => render_to_string(partial: 'answers/status', locals: { answer: @answer}, formats: [:html])
        },
        "section" => {
          "id" => @section.id,
          "progress" => render_to_string(partial: '/org_admin/sections/progress', locals: { section: @section, plan: @plan }, formats: [:html])
        },
        "plan" => {
          "id" => @plan.id,
          "progress" => render_to_string(:partial => 'plans/progress', locals: { plan: @plan, current_phase: @section.phase }, formats: [:html])
        }
      }.to_json
    end

  end # End update

  private
    def permitted_params
      permitted = params.require(:answer).permit(:id, :text, :plan_id, :user_id, :question_id, :lock_version, :question_option_ids => [])
      if !params[:answer][:question_option_ids].nil? && !permitted[:question_option_ids].present? #If question_option_ids has been filtered out because it was a scalar value (e.g. radiobutton answer)
        permitted[:question_option_ids] = [params[:answer][:question_option_ids]] # then convert to an Array
      end
      if !permitted[:id].present?
        permitted.delete(:id)
      end
      return permitted
    end # End permitted_params
end
