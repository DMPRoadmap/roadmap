module OrgAdmin
  class AnnotationsController < ApplicationController
    include Versionable

    respond_to :html
    after_action :verify_authorized

    def create
      annotation = nil
      begin
        annotation = Annotation.new(
          create_or_update_params.merge({ org_id: current_user.present? ? current_user.org_id : nil }))
      rescue ActionController::ParameterMissing
        skip_authorization
        flash[:alert] = _('Missing parameter(s) while attempting to create the annotation')
        redirect_to(org_admin_templates_path) and return
      end
      authorize annotation
      begin
        annotation = get_new(annotation)
        if annotation.save
          flash[:notice] = success_message(_('annotation'), _('created'))
        else
          flash[:alert] = failed_create_error(annotation, _('annotation'))
        end
      rescue StandardError
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      redirect_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    end

    def update
      annotation = Annotation.find(params[:id])
      authorize annotation
      begin
        annotation = get_modifiable(annotation)
        if annotation.update_attributes(
          create_or_update_params.merge({ org_id: current_user.org_id }))
          flash[:notice] = success_message(_('annotation'), _('updated'))
        else
          flash[:alert] = failed_update_error(annotation, _('annotation'))
        end
      rescue ActionController::ParameterMissing
        flash[:alert] = _('Missing parameter(s) while attempting to create the annotation')
      rescue StandardError
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      redirect_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    end

    def destroy
      annotation = Annotation.find(params[:id])
      authorize annotation
      begin
        annotation = get_modifiable(annotation)
        if annotation.destroy
          flash[:notice] = success_message(_('annotation'), _('removed'))
        else
          flash[:alert] = failed_destroy_error(annotation, _('annotation'))
        end
      rescue StandardError
        flash[:alert] = _('Unable to create a new version of this template.')
      end
      redirect_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    end

    private
      def create_or_update_params
        params.require(:annotation).permit(:question_id, :text, :type).tap do |annotation_params|
          annotation_params.require(:question_id)
          annotation_params.require(:text)
          annotation_params.require(:type)
        end
      end
  end
end
