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
    org_id_new_format = {id: record.id, name: record.org_name}.to_json

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

      unless full_org_json&.key?('orgs')
        puts 'Invalid response or no orgs key found'
        # Add Other org
        result = [other_org_json]
        render json: result, status: :ok
        return
      end

      # Extract the values from API result
      result = full_org_json['orgs'].map do |org| 
        title = org['names'].find { |n| n['types'].include?('ror_display') }
        # ror_id_formatted = org['id'].split('/').last
        org_id_new_format = {name: title['value']}.to_json
        {
          id: org_id_new_format,
          org_name: title ? title['value'] : 'Name not found',
          domain: '',
        }
      rescue => e
        puts "Failed request: #{e.message}"
        # If the request fails, log the error and return an empty array
        result = []
      end

      # Add Other org to end of array.
      result << other_org_json
    end
    render json: result, status: :ok
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  def show
    @org_domains = OrgDomain.where(org_id: current_user.org_id).order(created_at: :desc)
  end

  def new
    @org_domain = OrgDomain.new
  end

  def create
    domain_input = params[:org_domain][:domain].to_s.downcase.gsub(/\s+/, '')

    if domain_input.blank?
      flash.now[:alert] = "Domain can't be blank."
      @org_domain = OrgDomain.new
      render :new and return
    end

    @org_domain = OrgDomain.new(domain: domain_input, org_id: current_user.org_id)
    @org_domain.org_id = current_user.org_id

    if @org_domain.save
      redirect_to org_domain_show_path, notice: "Domain created successfully."
    else
      render :new
    end
  end

  def edit
    @org_domain = OrgDomain.find(params[:id])
    redirect_to org_domain_show_path, alert: "Unauthorized" unless @org_domain.org_id == current_user.org_id
  end

  def update
    @org_domain = OrgDomain.find(params[:id])
  
    if @org_domain.org_id != current_user.org_id
      redirect_to org_domain_show_path, alert: "Unauthorized"
    else
      domain_input = params[:org_domain][:domain].to_s.downcase.gsub(/\s+/, '')
  
      if domain_input.blank?
        flash.now[:alert] = "Domain can't be blank."
        render :edit and return
      end
  
      if @org_domain.update(domain: domain_input)
        redirect_to org_domain_show_path, notice: "Domain updated successfully."
      else
        render :edit
      end
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
    org_id_new_format = { id: other_org.id, name: other_org.name }.to_json
    {
      id: org_id_new_format,
      org_name: other_org.name,
      domain: "",
    }
  end
end

