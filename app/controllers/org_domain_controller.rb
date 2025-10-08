# frozen_string_literal: true

# Controller for API routes that return orgs by domain.
class OrgDomainController < ApplicationController

  # PUTS /orgs-by-domain with parameter email.
  # TBD: Change these Rubocop Cops
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def index
    email_param = search_params[:email]
    email_domain = email_param.split('@').last if email_param.present? && email_param.include?('@')
    render json: [], status: :ok if email_domain.blank?

    # check if org exists already using domain provided
    org_results = OrgDomain.search_with_org_info(email_domain)
    result = org_results.map { |record|
      org_id_new_format = { id: record.id, name: record.org_name }.to_json

      {
        id: org_id_new_format,
        org_name: record.org_name,
        domain: record.domain,
      }
    }

    unless result.empty?
      # Add Other org to end of array
      result << other_org_json
      puts "result: #{result}"
      render json: result, status: :ok
      return
    end

    # if org doesn't exist already call Orion API by passing domain
    begin
      full_org_json = ::ExternalApis::OrionService.search_by_domain(email_domain)
      puts "full_org_json: #{full_org_json}"

      # If no orgs found, retry with higher level domain by removing subdomains
      split_domain = email_domain.split('.')

      while !full_org_json&.key?('orgs') && split_domain.length > 2
        split_domain.shift
        domain_to_search = split_domain.join('.')
        puts "Retrying with #{domain_to_search}"
        full_org_json = ::ExternalApis::OrionService.search_by_domain(domain_to_search)
        puts "Retry full_org_json with #{domain_to_search}: #{full_org_json}"
      end

      unless full_org_json&.key?('orgs')
        puts 'Invalid response or no orgs key found'
        # Add Other org
        result = [other_org_json]
        render json: result, status: :ok
        return
      end

      # Extract the values from API result
      result = full_org_json['orgs'].map do |org|
        #  The ror_display value will be in the language of the country, and should always be present.
        ror_display_name_json = org['names'].find { |n| n['lang'] && n['types']&.include?('ror_display') }
        # puts "ror_display_name_json: #{ror_display_name_json}"
        org_name = ror_display_name_json ? ror_display_name_json['value'] : nil
        puts "org_name: #{org_name}"

        # If org_name is nil, skip this org
        break if org_name.nil?

        org_id_new_format = { name: org_name }.to_json
        {
          id: org_id_new_format,
          org_name: org_name,
          domain: ''
        }

      rescue StandardError => e
        puts "Failed request: #{e.message}"
      end

      # In case result is nil, we need to set it to an empty array
      result = [] if result.nil?
      # Add Other org to end of array.
      result << other_org_json
    end
    render json: result, status: :ok
  end

  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def show
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.can_org_admin? || current_user.can_super_admin?
    @org_domains = OrgDomain.where(org_id: current_user.org_id).order(:domain)
  end

  def new
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.can_org_admin? || current_user.can_super_admin?
    @org_domain = OrgDomain.new
  end

  # rubocop:disable Metrics/AbcSize
  def create
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.can_org_admin? || current_user.can_super_admin?
    domain_input = params[:org_domain][:domain].to_s.downcase.gsub(/\s+/, '')

    if domain_input.blank?
      flash.now[:alert] = 'Domain cannot be blank.'
      @org_domain = OrgDomain.new
      render :new and return
    end

    @org_domain = OrgDomain.new(domain: domain_input, org_id: current_user.org_id)
    @org_domain.org_id = current_user.org_id

    if @org_domain.save
      redirect_to org_domain_show_path, notice: 'Domain created successfully.'
    else
      render :new
    end
  end
  # rubocop:enable Metrics/AbcSize

  def edit
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.can_org_admin? || current_user.can_super_admin?
    @org_domain = OrgDomain.find(params[:id])
    redirect_to org_domain_show_path, alert: 'Unauthorized' unless @org_domain.org_id == current_user.org_id
  end

  # rubocop:disable Metrics/AbcSize
  def update
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.can_org_admin? || current_user.can_super_admin?
    @org_domain = OrgDomain.find(params[:id])

    if @org_domain.org_id == current_user.org_id
      domain_input = params[:org_domain][:domain].to_s.downcase.gsub(/\s+/, '')

      if domain_input.blank?
        flash.now[:alert] = 'Domain cannot be blank.'
        render :edit and return
      end

      if @org_domain.update(domain: domain_input)
        redirect_to org_domain_show_path, notice: 'Domain updated successfully.'
      else
        render :edit
      end
    else
      redirect_to org_domain_show_path, alert: 'Unauthorized'
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    redirect_to root_path, alert: "You are not authorized to view this page." unless current_user.can_org_admin? || current_user.can_super_admin?
    @org_domain = OrgDomain.find(params[:id])

    if @org_domain.org_id != current_user.org_id
      redirect_to org_domain_show_path, alert: 'Unauthorized'
      return
    end

    if @org_domain.destroy
      redirect_to org_domain_show_path, notice: 'Domain deleted successfully.'
    else
      redirect_to org_domain_show_path, alert: 'Failed to delete domain.'
    end
  end

  private

  # Using Strong Parameters ensure only domain is permitted
  def search_params
    params.permit(:email, :format, :org_domain)
  end

  def org_domain_params
    params.require(:org_domain).permit(:domain)
  end

  def other_org_json
    other_org = Org.find_other_org
    # add if condition here to check if other_org is nil or present
    org_id_new_format = other_org.present? ? { id: other_org.id, name: other_org.name }.to_json : { name: 'Other' }.to_json
    {
      id: org_id_new_format,
      org_name: other_org ? other_org.name : 'Other',
      domain: ''
    }
  end
end
