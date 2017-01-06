class OrgsController < ApplicationController
  after_action :verify_authorized

  ##
  # GET /organisations/1
  def admin_show
    @organisation = Org.find(params[:id])
    authorize @organisation
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  ##
  # GET /organisations/1/edit
  def admin_edit
    @organisation = Org.find(params[:id])
    authorize @organisation
    @languages = Language.all.order("name")
  end

  ##
  # PUT /organisations/1
  def admin_update
    @organisation = Org.find(params[:id])
    authorize @organisation
    @organisation.banner_text = params["org_banner_text"]
    @organisation.logo = params[:organisation][:logo] if params[:organisation][:logo]
    assign_params = params[:organisation].dup
    assign_params.delete(:logo)
    assign_params.delete(:contact_email) unless params[:organisation][:contact_email].present?

    respond_to do |format|
      begin
        if @organisation.update_attributes(assign_params)
          format.html { redirect_to admin_show_organisation_path(params[:id]), notice: I18n.t("admin.org_updated_message")  }
        else
          flash[:noice] = @organisation.errors.collect{|e| e.message}.join('<br />').html_safe
          format.html { render action: "admin_edit" }
        end
      rescue Dragonfly::Job::Fetch::NotFound => dflye
        flash[:notice] = I18n.t("admin.org_bad_logo")
        format.html {render action: "admin_edit"}
      end
    end
  end
end
