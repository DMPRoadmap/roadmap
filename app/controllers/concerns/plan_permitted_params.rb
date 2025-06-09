# frozen_string_literal: true

module PlanPermittedParams 
  extend ActiveSupport::Concern

  def plan_permitted_params
    [
      :created,
      :title, 
      :description, 
      :language, 
      :ethical_issues_exist,
      :ethical_issues_description,
      :ethical_issues_report,
      { dmp_ids: identifier_permitted_params },
      { contact: contributor_permitted_params },
      { contributors: contributor_permitted_params },
      { costs: cost_permitted_params },
      { project: project_permitted_params },
      { datasets: dataset_permitted_params }
    ]
  end

  def identifier_permitted_params
    [
      :type,
      :identifier
    ]
  end

  def contributor_permitted_params
    [
      :firstname, 
      :surname, 
      :mbox, 
      :role,
      { affiliations: affiliation_permitted_params },
      { contributor_ids: identifier_permitted_params }
    ]
  end

  def affiliation_permitted_params
    [
      :name, 
      :abbreviation,
      { affiliation_ids: identifier_permitted_params }
    ]
  end

  def cost_permitted_params
    [
      :title,
      :description, 
      :value, 
      :currency_code
    ]
  end

  def project_permitted_params
    [
      :title, 
      :description, 
      :start_on, 
      :end_on,
      { funding: funding_permitted_params }
    ]
  end

  def funding_permitted_params
    [
      :name,
      :funding_status,
      { funder_ids: identifier_permitted_params },
      { grant_ids: identifier_permitted_params }
    ]
  end

  def dataset_permitted_params
    [
      :title,
      :doi_url,
      :description, 
      :type, 
      :issued, 
      :language, 
      :personal_data, 
      :sensitive_data,
      :keywords,
      :data_quality_assurance, 
      :preservation_statement,
      { dataset_ids: identifier_permitted_params },
      { metadata: metadatum_permitted_params },
      { security_and_privacy_statements: security_and_privacy_statement_permitted_params },
      { technical_resources: technical_resource_permitted_params },
      { distributions: distribution_permitted_params }
    ]
  end

  def metadatum_permitted_params
    [
      :description,
      :language,
      { identifier: identifier_permitted_params }
    ]
  end

  def security_and_privacy_statement_permitted_params
    [
      :title,
      :description
    ]
  end

  def technical_resource_permitted_params
    [
      :description,
      { identifier: identifier_permitted_params }
    ]
  end

  def distribution_permitted_params
    [
      :title,
      :description,
      :format,
      :byte_size, 
      :access_url, 
      :download_url,
      :data_access,
      :available_until,
      { licenses: license_permitted_params }, 
      { host: host_permitted_params }
    ]
  end

  def license_permitted_params
    [
      :license_ref,
      :start_date
    ]
  end

  def host_permitted_params
    [
      :title,
      :description,
      :supports_versioning,
      :backup_type,
      :backup_frequency,
      :storage_type,
      :availability,
      :geo_location,
      :certified_with,
      :pid_system,
      { host_ids: identifier_permitted_params }
    ]
  end

end