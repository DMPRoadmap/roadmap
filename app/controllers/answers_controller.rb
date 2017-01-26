class AnswersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
	# POST /answers
  # current implimentation creates a new answer each time one is submitted
  #
  # Probably should rename from from create to update
  #   Maybe better to just update the existing answer rather than generate a new
  #   one.  Especiall since comments connect to answers
	def create
    # create a new answer based off the passed params
		@answer = Answer.new(params[:answer])
    authorize @answer
    # find the prevous answer to this question for this plan (created_at: "DESC").first
		old_answer = @answer.plan.answer(@answer.question_id, false)
		proceed = false
    # confused why we are passing the text through like this if we have clearly passed the answer's other attr through plainly
    # We can re-name it as it's defined in app/views/plans/_answer_form.html.erb
		@answer.text = params["answer-text-#{@answer.question_id}".to_sym]
		if (old_answer.nil? && @answer.text != "") || ((!old_answer.nil?) && (old_answer.text != @answer.text)) then
			proceed = true
		end
    # Is this validation necissary?
		if (@answer.question.question_format.title == I18n.t("helpers.checkbox") ||
        @answer.question.question_format.title == I18n.t("helpers.multi_select_box") ||
        @answer.question.question_format.title == I18n.t("helpers.radio_buttons") ||
        @answer.question.question_format.title == I18n.t("helpers.dropdown")) then
			if (old_answer.nil? && @answer.option_ids.count > 0) || ((!old_answer.nil?) && (old_answer.option_ids - @answer.option_ids).count != 0 && (@answer.option_ids - old_answer.option_ids).count != 0) then
				proceed = true
			end
		end

		if proceed
			if @answer.save
				redirect_to :back, status: :found, notice: I18n.t('helpers.project.answer_recorded')
			else
				redirect_to :back, notice: I18n.t('helpers.project.answer_error')
			end
		else
			redirect_to :back, notice: I18n.t('helpers.project.answer_no_change')
		end
  end
end