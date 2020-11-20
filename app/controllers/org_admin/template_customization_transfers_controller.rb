# frozen_string_literal: true

class OrgAdmin::TemplateCustomizationTransfersController < ApplicationController

  after_action :verify_authorized

  # POST /org_admin/templates/:id/transfer_customization
  #
  # The funder template's id is passed through here
  def create
    @template = Template.find(params[:template_id])
    authorize @template, :transfer_customization?
    if @template.upgrade_customization?
      @new_customization = @template.upgrade_customization!
      redirect_to org_admin_template_path(@new_customization)
    else
      flash[:alert] = _("That template is no longer customizable.")
      redirect_back(fallback_location: org_admin_templates_path)
    end
  end

end
