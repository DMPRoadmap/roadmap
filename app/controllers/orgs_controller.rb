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
    attrs = org_params
    @org = Org.find(params[:id])
    authorize @org
    @org.banner_text = params["org_banner_text"]
    @org.logo = org_params[:logo] if org_params[:logo]

    begin
      if @org.update_attributes(org_params)
        redirect_to admin_show_org_path(params[:id]), notice: _('Organisation was successfully updated.')
      else
        # For some reason our custom validator returns as a string and not a hash like normal activerecord 
        # errors. We followed the example provided in the Rails guides when building the validator so
        # its unclear why its doing this. Placing a check here for the data type. We should reasses though
        # when doing a broader eval of the look/feel of the site and we come up with a standardized way of
        # displaying errors
        flash[:notice] = failed_update_error(@org, _('organisation'))
        render action: "admin_edit"
      end
    rescue Dragonfly::Job::Fetch::NotFound => dflye
      flash[:notice] = _('There seems to be a problem with your logo. Please upload it again.')
      render action: "admin_edit"
    end
  end

  private
    def org_params
      params.require(:org).permit(:name, :abbreviation, :target_url, :is_other, :banner_text, :language_id,
                                  :region_id, :logo, :contact_email, :remove_logo)
    end
end
