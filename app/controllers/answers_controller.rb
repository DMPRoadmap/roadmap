class AnswersController < ApplicationController
  after_action :verify_authorized
  respond_to :html

	# PUT/PATCH /[:locale]/answer/[:id]
	def update
    question_id = params[:answer][:question_id]
    plan_id = params[:answer][:plan_id]
    @question = Question.find(question_id);
    # If an answer id is present load that answer otherwise load by plan/question
    @answer = Answer.find_by(plan_id: plan_id, question_id: question_id)

    @old_answer = nil
    @timestamp = nil

    if @answer.nil? # If there is no answer for plan/question
      @answer = Answer.new(permitted_params)
      @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
      
      authorize @answer

      if @answer.save
        @timestamp = @answer.updated_at.iso8601
      end
      @lock_version = @answer.lock_version
    elsif params[:answer][:id].blank? # Someone else already added an answer while the user was working
      @old_answer = Marshal::load(Marshal.dump(@answer))
      @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
    
      authorize @answer
      
      @lock_version = @answer.lock_version
    else  # We're about updating an answer (let ActiveRecord check for a race condition)
      @old_answer = Marshal::load(Marshal.dump(@answer))
      @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
      
      authorize @answer
      
      if @answer.update(permitted_params)
        @answer.touch # Saves the record with the updated_at set to the current time. Needed if only answer.question_options is updated
        @timestamp = @answer.updated_at.iso8601
      end
      @lock_version = @answer.lock_version
      @old_answer = nil
    end

    @plan = Plan.includes({
      sections: { 
        questions: [ 
          :answers,
          :question_format
        ]
      }
    }).find(plan_id)
    @section = @plan.get_section(@question.section_id)
    @username = @answer.user.name

    respond_to do |format|
      format.js {} 
    end

    rescue ActiveRecord::StaleObjectError
      @username = @old_answer.user.name
      @lock_version = @old_answer.lock_version
      respond_to do |format|
        format.js {}
      end

  end # End update

  private
    def permitted_params
      permitted = params.require(:answer).permit(:id, :plan_id, :user_id, :question_id, :lock_version, :question_option_ids => [])
      if !permitted[:question_option_ids].present?  #If question_option_ids has been filtered out because it was a scalar value (e.g. radiobutton answer)
        permitted[:question_option_ids] = [params[:answer][:question_option_ids]] # then convert to an Array
      end
      return permitted
    end # End permitted_params
end
