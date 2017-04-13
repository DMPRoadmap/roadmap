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
    # If an answer id is present load that answer otherwise load by plan/question
    @answer = Answer.find_by(plan_id: plan_id, question_id: question_id)

    @old_answer, race_on_creation = nil, false

    # This is the first answer for the question
    if @answer.nil?
puts"CREATING"
      @answer = Answer.new(params[:answer])
      @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
      authorize @answer
      @answer.save
    
    # Someone else already added an answer while the user was working
    elsif ans_params[:id].nil?
puts"RACE"
      @old_answer = Marshal::load(Marshal.dump(@answer))
      authorize @answer
      race_on_creation = true
      
    # We're updating an answer (let ActiveRecord check for a race condition)
    else
puts"UPDATING"
      # if you do the obvious clone here it will overwrite the old_answer text
      # in the next line
      #@old_answer = @answer.clone
      @old_answer = Marshal::load(Marshal.dump(@answer))
      @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
      authorize @answer
      @answer.update(params[:answer])
    end

    @section_id = @answer.question.section.id

    # these are used for updating the status line
    @username = @answer.user.name
    @timestamp = ""

    if @answer.text.present?
      @timestamp = @answer.updated_at.iso8601
    end


    @nquestions = 0
    @nanswers = 0
    @n_section_questions = 0
    @n_section_answers = 0

    plan = Plan.find(plan_id)
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
puts "OLD: #{@old_answer.inspect}"
puts "CURR: #{@answer.inspect}"
      @lock_version = (@old_answer.nil? ? @answer.lock_version : @old_answer.lock_version)
      
      if !race_on_creation
        # pass new lock_version back to the client or they'll never save again
        @old_answer = nil
        
      else
        @answer = Answer.new(params[:answer])
        @answer.text = params["answer-text-#{@answer.question_id}".to_sym]
      end
      
      format.js {} 
    end

    rescue ActiveRecord::StaleObjectError
        @lock_version = @old_answer.lock_version
        respond_to do |format|
          format.js {}
        end
    end

end
