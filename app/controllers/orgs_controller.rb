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
        # For some reason our custom validator returns as a string and not a hash like normal activerecord 
        # errors. We followed the example provided in the Rails guides when building the validator so
        # its unclear why its doing this. Placing a check here for the data type. We should reasses though
        # when doing a broader eval of the look/feel of the site and we come up with a standardized way of
        # displaying errors
        flash[:notice] = @org.errors.collect{|a, e| "#{a} - #{(e.instance_of?(String) ? e : e.message)}"}.join('<br />').html_safe
        render action: "admin_edit"
      end
    rescue Dragonfly::Job::Fetch::NotFound => dflye
      flash[:notice] = _('There seems to be a problem with your logo. Please upload it again.')
      render action: "admin_edit"
    end
  end
end
