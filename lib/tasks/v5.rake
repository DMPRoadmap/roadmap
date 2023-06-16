# frozen_string_literal: true

# Upgrade tasks for 5.x versions. See https://github.com/DMPRoadmap/roadmap/releases for information
# on how and when to run each task.

# rubocop:disable Naming/VariableNumber
namespace :v5 do
  # TODO: In the next release drop column repositories.custom_repository_owner_template_id
  # TODO: In the next release drop columns output_type & output_type_description from research_outputs

  desc 'Upgrade from v4.x to v5.0'
  task upgrade_5_0: :environment do
    puts 'Adding Funder API information for new React UI project/award search'
    host = Rails.env.development? ? 'http://localhost:3000' : ENV['DMPROADMAP_HOST']

    # Funders that have Crossref Grant Ids
    crossref_funder_ids = ['100004440', '100000015', '501100002241', '100001545', '100001771', '100000048', '100000980',
                           '501100001821', '100000968', '100008984', '100000893', '100000971', '100005202', '100000936',
                           '100000913', '100005190', '100005536', '501100000223', '100006309', '100010586', '100008539',
                           '501100011730', '100010581']
    RegistryOrg.where(fundref_id: crossref_funder_ids).where(api_target: nil).each do |ror_org|
      ror_org.update(
        api_target: "#{host}/api/v3/awards/crossref/10.13039/#{ror_org.fundref_id}",
        api_guidance: 'Please enter an award DOI (e.g. 10.12345/abcd.proj.2008/abc123) or a combination of title keywords, PI names and the award year.',
        api_query_fields: '[{"label": "Award DOI", "query_string_key": "project"}, {"label": "PI names", "query_string_key": "pi_names"}, {"label": "Title keywords", "query_string_key": "title"}, {"label": "Award year", "query_string_key": "years"}]'
      )
    end

    # Funders that use the NIH Awards API
    RegistryOrg.where('LOWER(name) LIKE ?', '%nih.gov%').where(api_target: nil).each do |ror_org|
      ror_org.update(
        api_target: "#{host}/api/v3/awards/nih",
        api_guidance: 'Please enter a project/application id (e.g. 5R01AI00000, 1234567) or a combination of title keywords, PI names, FOA opportunity id (e.g. PA-11-111) and the award year.',
        api_query_fields: '[{"label": "Project/Application id", "query_string_key": "project"}, {"label": "FOA opportunity id", "query_string_key": "opportunity"}, {"label": "PI names", "query_string_key": "pi_names"}, {"label": "Title keywords", "query_string_key": "title"}, {"label": "Award year", "query_string_key": "years"}]'
      )
    end

    RegistryOrg.where('LOWER(name) LIKE ? OR LOWER(name) LIKE ?', '%nasa.gov%', '%nsf.gov%').where(api_target: nil).each do |ror_org|
      ror_org.update(
        api_target: "#{host}/api/v3/awards/nsf",
        api_guidance: 'Please enter an award id (e.g. 1234567) or a combination of title keywords, PI names and the award year.',
        api_query_fields: '[{"label": "Award id", "query_string_key": "project"}, {"label": "PI names", "query_string_key": "pi_names"}, {"label": "Title keywords", "query_string_key": "title"}, {"label": "Award year", "query_string_key": "years"}]'
      )
    end

    puts 'The following RegistryOrg records now have award/grant API information for the React UI.'
    RegistryOrg.where.not(api_target: nil).each do |ror_org|
      puts "      ID: #{ror_org.id}   |   NAME: #{ror_org.name}   |   API_TARGET: #{ror_org.api_target}"
    end
  end
end
# rubocop:enable Naming/VariableNumber
