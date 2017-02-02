class PhasesController < ApplicationController

  after_action :verify_authorized

  TEXTAREA = QuestionFormat.where(title: "Text area").first.id
  TEXTFIELD = QuestionFormat.where(title: "Text field").first.id
  RADIO = QuestionFormat.where(title: "Radio buttons").first.id
  CHECKBOX = QuestionFormat.where(title: "Check box").first.id
  DROPDOWN = QuestionFormat.where(title: "Dropdown").first.id
  MULTI = QuestionFormat.where(title: "Multi select box").first.id
  
	# GET /phases/1/edit
	def edit
    
    @textarea = TEXTAREA
    @textfield = TEXTFIELD
    @radio = RADIO
    @checkbox = CHECKBOX
    @dropdown = DROPDOWN
    @multi = MULTI

    @plan = Plan.find(params[:plan_id])
    authorize @plan
		@phase = Phase.where(template_id: @plan.template_id, slug: params[:id]).first

    @sections = @phase.sections
    @section_answers = Hash.new
    @phase.sections.each do |section|
      nanswers = 0
      questions = section.questions
      questions.each do |q| 
        answers = q.answers.where(plan_id: @plan)
        nanswers += answers.count
      end
      @section_answers[section.id] = nanswers
    end

    if !user_signed_in? then
      respond_to do |format|
				format.html { redirect_to edit_user_registration_path }
			end
		end

	end


end
