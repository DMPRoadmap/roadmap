# frozen_string_literal: true

class OrgAdmin::TemplateCustomizationTransfersController < ApplicationController

  include Versionable

  after_action :verify_authorized

  # POST /org_admin/templates/:id/transfer_customization
  #
  # The funder template's id is passed through here
  def create
    @template = Template.find(params[:template_id])
    authorize @template, :transfer_customization?
    if @template.upgrade_customization?
      # If the customized template is not published it will not version, so publish it!
      previously_published = @template.published?
      @template.publish unless previously_published

      @new_customization = @template.upgrade_customization!

      # Reset the published flag if the customized template was not previously published
      @template.update(published: false) unless previously_published

      redirect_to org_admin_template_path(@new_customization)
    else
      flash[:alert] = _("That template is no longer customizable.")
      redirect_back(fallback_location: org_admin_templates_path)
    end
  end

end
