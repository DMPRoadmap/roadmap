class AnswersController < ApplicationController
  after_action :verify_authorized

	# POST /answers
	def create
		@answer = Answer.new(params[:answer])
    authorize @answer
		old_answer = @answer.plan.answer(@answer.question_id, false)
		proceed = false
		@answer.text = params["answer-text-#{@answer.question_id}".to_sym]
		if (old_answer.nil? && @answer.text != "") || ((!old_answer.nil?) && (old_answer.text != @answer.text)) then
			proceed = true
		end
          
		if (@answer.question.question_format.title == I18n.t("helpers.checkbox") || 
              @answer.question.question_format.title == I18n.t("helpers.multi_select_box") ||
              @answer.question.question_format.title == I18n.t("helpers.radio_buttons") || 
              @answer.question.question_format.title == I18n.t("helpers.dropdown")) then
			if (old_answer.nil? && @answer.option_ids.count > 0) || ((!old_answer.nil?) && (old_answer.option_ids - @answer.option_ids).count != 0 && (@answer.option_ids - old_answer.option_ids).count != 0) then
				proceed = true
			end
		end
		if proceed
			respond_to do |format|
				if @answer.save
					format.html { redirect_to :back, status: :found, notice: I18n.t('helpers.project.answer_recorded') }
				else
					format.html { redirect_to :back, notice: I18n.t('helpers.project.answer_error') }
				end
			end
		else
			respond_to do |format|
				format.html { redirect_to :back, notice: I18n.t('helpers.project.answer_no_change') }
			end
		end
  end
end