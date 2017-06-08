class OrgsController < ApplicationController
  after_action :verify_authorized, except: ['shibboleth_ds', 'shibboleth_ds_passthru']
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

  # GET /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds
    redirect_to root_path unless current_user.nil?
    
    @user = User.new
    # Display the custom Shibboleth discovery service page. 
    @orgs = Org.joins(:identifier_schemes).where('identifier_schemes.name = ?', 'shibboleth').sort{|x,y| x.name <=> y.name }
  end

  # POST /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds_passthru
    if !params[:org_name].blank?
      session['org_id'] = params[:org_name]
    elsif session['org_id'].blank?
      flash[:notice] = _('Please choose an institution')
      redirect_to shibboleth_ds_path
    end
    
    scheme = IdentifierScheme.find_by(name: 'shibboleth')
    shib_entity = OrgIdentifier.where(org_id: params[:org_name], identifier_scheme: scheme)
    
    if !shib_entity.empty?
      # Force SSL
      url = "#{request.base_url.gsub('http:', 'https:')}#{Rails.application.config.shibboleth_login}"
      target = "#{user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')}"
      
      #initiate shibboleth login sequence
      redirect_to "#{url}?target=#{target}&entityID=#{shib_entity.first.identifier}"
    else
      flash[:notice] = _('Your institution does not seem to be properly configured.')
      redirect_to shibboleth_ds_path
    end
  end

  private
    def org_params
      params.require(:org).permit(:name, :abbreviation, :target_url, :is_other, :banner_text, :language_id,
                                  :region_id, :logo, :contact_email)
    end
end
