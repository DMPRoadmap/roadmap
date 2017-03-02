class OrgsController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # GET /organisations/1
  def admin_show
    @org = Org.find(params[:id])
    authorize @org
  end

  ##
  # GET /organisations/1/edit
  def admin_edit
    @org = Org.find(params[:id])
    authorize @org
    @languages = Language.all.order("name")
  end

  ##
  # PUT /organisations/1
  def admin_update
    @org = Org.find(params[:id])
    authorize @org
    @org.banner_text = params["org_banner_text"]
    @org.logo = params[:org][:logo] if params[:org][:logo]
    assign_params = params[:org].dup
    assign_params.delete(:logo)
    assign_params.delete(:contact_email) unless params[:org][:contact_email].present?

    begin
      if @org.update_attributes(assign_params)
        redirect_to admin_show_org_path(params[:id]), notice: _('Organisation was successfully updated.')
      else
        flash[:notice] = @org.errors.collect{|e| e.message}.join('<br />').html_safe
        render action: "admin_edit"
      end
    rescue Dragonfly::Job::Fetch::NotFound => dflye
      flash[:notice] = _('There seems to be a problem with your logo. Please upload it again.')
      render action: "admin_edit"
    end
  end
end
