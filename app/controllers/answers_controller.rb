class AnswersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
	# PUT/PATCH /[:locale]/answer/[:id]
	def update
    # create a new answer based off the passed params

    ans_params = params[:answer]
    plan_id = ans_params[:plan_id]
    user_id = ans_params[:user_id]
    question_id = ans_params[:question_id]
		@answer = Answer.find_by(
                        plan_id: plan_id,
                        user_id: user_id,
                        question_id: question_id)
    if @answer.nil?
      @answer = Answer.new(params[:answer])
    end

    authorize @answer

puts params.inspect

		@answer.text = params["answer-text-#{@answer.question_id}".to_sym]

    #TODO: check for optimistic locking

    # Is this validation necessary?
#		if (@answer.question.question_format.title == I18n.t("helpers.checkbox") ||
#        @answer.question.question_format.title == I18n.t("helpers.multi_select_box") ||
#        @answer.question.question_format.title == I18n.t("helpers.radio_buttons") ||
#        @answer.question.question_format.title == I18n.t("helpers.dropdown")) then
#			if (old_answer.nil? && @answer.option_ids.count > 0) || ((!old_answer.nil?) && (old_answer.option_ids - @answer.option_ids).count != 0 && (@answer.option_ids - old_answer.option_ids).count != 0) then
#				proceed = true
#			end
#		end

#		if proceed
			if @answer.save
				redirect_to :back, status: :found, notice: I18n.t('helpers.project.answer_recorded')
			else
				redirect_to :back, notice: I18n.t('helpers.project.answer_error')
			end
#		else
#			redirect_to :back, notice: I18n.t('helpers.project.answer_no_change')
#		end
  end
end
