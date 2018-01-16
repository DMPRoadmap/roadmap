class AnswersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

	# PUT/PATCH /answers/[:id]
  def update
    p_params = permitted_params()
    Answer.transaction do
      @answer = Answer.find_by({plan_id: p_params[:plan_id], question_id: p_params[:question_id]})
      begin
        if @answer.present?
          authorize @answer
          @answer.update(p_params)
          if p_params[:question_option_ids].present?
            @answer.touch() # Saves the record with the updated_at set to the current time. Needed if only answer.question_options is updated
          end
        else
          @answer = Answer.new(p_params)
          @answer.lock_version = 1
          authorize @answer
          # NOTE: save! and destroy! must be used for transactions as they raise errors instead of returning false
          @answer.save!
        end
      rescue ActiveRecord::StaleObjectError
        @stale_answer = @answer
        @answer = Answer.find_by({plan_id: p_params[:plan_id], question_id: p_params[:question_id]})
      end
    end

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

    respond_to do |format|
      format.js {}
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
