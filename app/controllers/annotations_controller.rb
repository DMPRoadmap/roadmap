class AnnotationsController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  #update a example answer of a template
  def admin_update
    question = Question.includes(section: { phase: :template}).find(params[:question_id])
    authorize question

#    example_answer = Annotation.find_or_create_by(question: question, org: current_user.org, type: Annotation.types[:example_answer])
#    guidance = Annotation.find_or_create_by(question: question, org: current_user.org, type: Annotation.types[:guidance])
    
    hash = {question_id: question.id, org_id: current_user.org.id}
    process_changes(hash.merge({type: Annotation.types[:example_answer]}), params[:example_answer_text], _('example answer'))
    process_changes(hash.merge({type: Annotation.types[:guidance]}), params[:guidance_text], _('guidance'))

    if !flash[:notice].blank? || !flash[:alert].blank?
      template = question.section.phase.template
      template.dirty = true
      template.save!
    end
    redirect_to controller: :phases, action: :admin_show, id: question.section.phase.id
  end

  #delete an annotation
  def admin_destroy
    annotation = Annotation.find(params[:id])
    authorize annotation
    phase_id = Annotation.joins("INNER JOIN questions ON annotations.question_id = questions.id").joins("INNER JOIN sections ON questions.section_id = sections.id").joins("INNER JOIN phases ON sections.phase_id = phases.id").where("annotations.id": params[:id]).pluck("phases.id").first #annotation.question.section.phase.id
    if annotation.present?
      type = (annotation.type == Annotation.types[:example_answer] ? 'example answer' : 'guidance')
      if annotation.destroy!
        flash[:notice] = success_message(type, _('removed'))
      else
        flash[:alert] = failed_destroy_error(annotation, type)
      end
    end
    redirect_to controller: :phases, action: :admin_show, id: phase_id
  end

  private

  def init_annotation(text, question, org, type)
    annotation = Annotation.new
    annotation.org = org
    annotation.question = question
    annotation.text = text
    annotation.type = type
    return annotation
  end

  def process_changes(hash, input, type)
    # If the input is available update the annotation otherwise remove it if it exists
    if input.present? 
      annotation = Annotation.find_or_create_by(hash)
      if annotation.text != input
        annotation.text = input
        if annotation.save!
          flash[:notice] = "#{(flash[:notice].nil? ? '' : flash[:notice] + '<br>')}#{success_message(type, _('updated'))}"
        else
          flash[:alert] = "#{(flash[:alert].nil? ? '' : flash[:alert] + '<br>')}#{failed_update_error(annotation, type)}"
        end
      end
    else
      # If the user cleared the text and the record exists, delete it
      annotation = Annotation.find_by(hash)
      if annotation.present?
        if annotation.destroy!
          flash[:notice] = "#{(flash[:notice].nil? ? '' : flash[:notice] + '<br>')}#{success_message(type, _('removed'))}"
        else
          flash[:alert] = "#{(flash[:alert].nil? ? '' : flash[:alert] + '<br>')}#{failed_update_error(annotation, type)}"
        end
      end
    end
  end
end
