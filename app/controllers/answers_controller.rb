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

    @section_id = @answer.question.section.id
    @username = @answer.user.name

    @nquestions = 0
    @nanswers = 0
    @n_section_questions = 0
    @n_section_answers = 0

    plan = Plan.find(plan_id)
    # Problem of N+1 queries below
    plan.template.phases.each do |phase|
      phase.sections.each do |section|
        section.questions.each do |question|
          @nquestions += 1
          if section.id == @section_id
            @n_section_questions += 1
          end
          question.answers = question.answers.to_a.select {|answer| answer.plan_id == plan.id}
          if question.answers.present? && question.answers.first.text.present?
            @nanswers += 1
            if section.id == @section_id
              @n_section_answers += 1
            end
          end
        end
      end
    end

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
