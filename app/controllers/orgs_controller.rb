class OrgsController < ApplicationController
  after_action :verify_authorized, except: ['shibboleth_ds', 'shibboleth_ds_passthru']
  respond_to :html

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
    @org.logo = attrs[:logo] if attrs[:logo]
    failure = ''
    tab = (attrs[:feedback_enabled].present? ? 'feedback' : 'profile')
    
    if attrs[:links].present?
      if is_json_array_of_objects?(attrs[:links])
        json = JSON.parse(attrs[:links])
        # Make sure that the JSON hash is structured as: {"link":"string","text":"string"}
        if json.all?{ |o| o['link'].present? && o['text'].present? }
          @org.links = json
        else
          failure = _('Unable to save your changes. Invalid URLs.')
        end
      else
        failure = _('Unable to save your changes. Invalid URLs.')
      end
      attrs.delete('links')
    end
    
    begin
      if failure.blank? && @org.update_attributes(attrs)
        redirect_to "#{admin_edit_org_path(@org)}\##{tab}", notice: success_message(_('organisation'), _('saved'))
      else
        failure = failed_update_error(@org, _('organisation')) if failure.blank?
        redirect_to "#{admin_edit_org_path(@org)}\##{tab}", alert: failure
      end
    rescue Dragonfly::Job::Fetch::NotFound => dflye
      redirect_to "#{admin_edit_org_path(@org)}\##{tab}", alert: _('There seems to be a problem with your logo. Please upload it again.')
    end
  end

  # GET /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds
    redirect_to root_path unless current_user.nil?
    
    @user = User.new
    # Display the custom Shibboleth discovery service page. 
    @orgs = Org.joins(:identifier_schemes).where('identifier_schemes.name = ?', 'shibboleth').sort{|x,y| x.name <=> y.name }
    
    if @orgs.empty?
      flash[:alert] = _('No institutions are currently registered.')
      redirect_to user_shibboleth_omniauth_authorize_path 
    end
  end

  # POST /orgs/shibboleth_ds
  # ----------------------------------------------------------------
  def shibboleth_ds_passthru
    if !params[:org_name].blank?
      session['org_id'] = params[:org_name]

      scheme = IdentifierScheme.find_by(name: 'shibboleth')
      shib_entity = OrgIdentifier.where(org_id: params[:org_name], identifier_scheme: scheme)
    
      if !shib_entity.empty?
        # Force SSL
        url = "#{request.base_url.gsub('http:', 'https:')}#{Rails.application.config.shibboleth_login}"
        target = "#{user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')}"
      
        #initiate shibboleth login sequence
        redirect_to "#{url}?target=#{target}&entityID=#{shib_entity.first.identifier}"
      else
        flash[:alert] = _('Your institution does not seem to be properly configured.')
        redirect_to shibboleth_ds_path
      end

    else
      flash[:notice] = _('Please choose an institution')
      redirect_to shibboleth_ds_path
    end
  end

  private
    def org_params
      params.require(:org).permit(:name, :abbreviation, :logo, :contact_email, :contact_name, :remove_logo, :links,
                                  :feedback_enabled, :feedback_email_subject, :feedback_email_msg)
    end
end
