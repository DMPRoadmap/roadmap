class OrgAdmin::ConditionsController < ApplicationController

  def from_question
    @selected = Condition.where(question_id: :question_id)
    respond_to :js
      #format.html { render :form }
  end

	def new_or_edit
    begin
		  question_option = QuestionOption.find(params[:question_option_id])
      condition = question_option.conditions.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      condition = Condition.new(condition_params)
    end
    render '/questions/edit'
	end

	def create_or_update
    p_params = condition_params()

    # First it is checked question option exists and condition exists for that question option
    begin
      question = Question.find(p_params[:question_id])
      if !question.question_option_exists?(p_params[:question_option_id])
        # rubocop:disable LineLength
        render(status: :not_found, json: {
          msg: _("There is no question option with id %{question_option_id} associated to question id %{question_id} for which to create or update an answer") % {
            question_option_id: p_params[:question_option_id],
            question_id: p_params[:question_option_id]
          }
        })
        # rubocop:enable LineLength
        return
      end
    rescue ActiveRecord::RecordNotFound
      # rubocop:disable LineLength
      render(status: :not_found, json: {
        msg: _("There is no question with id %{id} for which to create or update an answer") % {
          id: p_params[:question_id]
        }
      })
      # rubocop:enable LineLength
      return
    end
    question_option = QuestionOption.find(p_params[:question_option_id])

    Condition.transaction do
      begin
        condition = Condition.find_by!(
          question_id: p_params[:question_id],
          question_option_id: p_params[:question_option_id]
          )
        # authorize condition  ?
      rescue ActiveRecord::RecordNotFound
        condition = Condition.new(p_params.merge(question_id: question.id))
        condition.save!
      end
    end
  end


	private
	def condition_params
		params.require(:question_option_id, :action_type).permit(:remove_question_id)
	end
end
				#INCOMPLETE
