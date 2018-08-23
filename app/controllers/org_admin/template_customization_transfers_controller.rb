# frozen_string_literal: true

class OrgAdmin::TemplateCustomizationTransfersController < ApplicationController

  after_action :verify_authorized

  # POST /org_admin/templates/:id/transfer_customization
  # the funder template's id is passed through here
  def create
    @template = Template.includes(:org).find(params[:template_id])
    authorize @template, :transfer_customization?
    if @template.upgrade_customization?
      begin
        new_customization = @template.upgrade_customization!
        redirect_to org_admin_template_path(new_customization)
      rescue StandardError => e
        flash[:alert] = _("Unable to transfer your customizations.")
        if request.referrer.present?
          redirect_to :back
        else
          redirect_to org_admin_templates_path
        end
      end
    else
      flash[:notice] = _("That template is no longer customizable.")
      if request.referrer.present?
        redirect_to :back
      else
        redirect_to org_admin_templates_path
      end
    end
  end

end
