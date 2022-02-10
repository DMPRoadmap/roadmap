# frozen_string_literal: true

class OrgAdmin::TemplateCopiesController < ApplicationController

  include TemplateMethods

  after_action :verify_authorized

  # POST /org_admin/templates/:id/copy (AJAX)
  def create
    @template = Template.find(params[:template_id])
    authorize @template, :copy?
    begin
      new_copy = @template.generate_copy!(current_user.org)
      flash[:notice] = "#{template_type(@template).capitalize} was successfully copied."
      redirect_to edit_org_admin_template_path(new_copy)
    rescue StandardError
      flash[:alert] = failure_message(_("copy"), template_type(@template))
      if request.referrer.present?
        redirect_back(fallback_location: org_admin_templates_path)
      else
        redirect_to org_admin_templates_path
      end
    end
  end

end
