class AnswersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
	# PUT/PATCH /[:locale]/answer/[:id]
	def update
    # create a new answer based off the passed params

    ans_params = params[:answer]
    plan_id = ans_params[:plan_id]
    phase_id = ans_params[:phase_id]
    user_id = ans_params[:user_id]
    lock_version = ans_params[:lock_version]
    question_id = ans_params[:question_id]
    @question = Question.find(question_id);
		@answer = Answer.find_by(
                        plan_id: plan_id,
                        user_id: user_id,
                        question_id: question_id)

    @old_answer = nil

    if @answer.nil?
      @answer = Answer.new(params[:answer])
      authorize @answer
			@answer.save
    else
      # if you do the obvious clone here it will overwrite the old_answer text
      # in the next line
      #@old_answer = @answer.clone
      @old_answer = Marshal::load(Marshal.dump(@answer))
      @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
      authorize @answer
      @answer.update(params[:answer])
    end

    respond_to do |format|
      # pass new lock_version back to the client or they'll never save again
      @lock_version = @answer.lock_version
      @old_answer = nil
      format.js {} 
    end

    rescue ActiveRecord::StaleObjectError
        @lock_version = @old_answer.lock_version
        respond_to do |format|
          format.js {}
        end
    end
end
