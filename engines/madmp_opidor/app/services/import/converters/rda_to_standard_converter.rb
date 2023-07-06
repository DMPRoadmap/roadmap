# frozen_string_literal: true

module Import
  module Converters
    # Service used to convert plan from RDA DMP Commons Standars Format
    # to Standard Format
    class RdaToStandardConverter
      class << self
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def convert(json)
          return {} unless json.present?

          {
            'meta' => {
              'creationDate' => json['created'],
              'description' => json['description'],
              'dmpId' => json.dig('dmp_id', 'identifier'),
              'idType' => json.dig('dmp_id', 'type'),
              'dmpLanguage' => json['language'],
              'lastModifiedDate' => json['modified'],
              'title' => json['title'],
              'license' => {},
              'licenseStartDate' => '',
              'relatedDoc' => [],
              'associatedDmp' => [],
              'contact' => {
                'person' => {
                  'personId' => json.dig('contact', 'contact_id', 'identifier'),
                  'idType' => json.dig('contact', 'contact_id', 'type'),
                  'mbox' => json.dig('contact', 'mbox'),
                  'lastName' => json.dig('contact', 'name')
                }
              }
            },
            'project' => convert_project(json['project']),
            'budget' => { 'cost' => convert_cost(json['cost']) },
            'researchOutput' => convert_research_output(json['dataset'], json)
          }
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        def convert_project(projects)
          return {} if projects.nil? || projects.empty?

          project = projects[0]
          {
            'description' => project['description'],
            'endDate' => project['end'],
            'funding' => convert_funding(project['funding']),
            'startDate' => project['start'],
            'title' => project['title']
          }
        end

        def convert_funding(fundings)
          return [] if fundings.nil?

          fundings_list = []
          fundings.each do |elem|
            fundings_list.append(
              {
                'funder' => {
                  'funderId' => elem.dig('funder_id', 'identifier'),
                  'idType' => elem.dig('funder_id', 'type')
                },
                'fundingStatus' => elem['funding_status'],
                'grantId' => elem.dig('grant_id', 'identifier')
              }
            )
          end
          fundings_list
        end

        # FROM
        # {
        #   "name": "DMP Administrator",
        #   "mbox": "dmp.opidor@inist.fr",
        #   "role": [
        #     "Coordinateur de projet",
        #     "Personne contact pour les données (Research Output 1, Research Output 2, Research Output 3)"
        #   ],
        #   "contributor_id": {
        #     "identifier": 1234,
        #     "type": "DOI"
        #   }
        # }
        # TO
        #
        # {
        #   "lastName": "DMP Administrator",
        #   "mbox": "dmp.opidor@inist.fr",
        #   "personId": 1234,
        #   "idType": "DOI"
        # }
        def convert_contributors(contributors)
          return [] if contributors.nil?

          contributors_list = []
          contributors.each do |contributor|
            contributors_list.append(
              {
                'lastName' => contributor['name'],
                'mbox' => contributor['mbox'],
                'personId' => contributor.dig('contributor_id', 'identifier'),
                'idType' => contributor.dig('contributor_id', 'type')

              }
            )
          end
          contributors_list
        end

        def convert_metadata(metadata)
          return [] if metadata.nil?

          metadata_list = []
          metadata.each do |elem|
            metadata_list.append(
              {
                'description' => elem['description'],
                'metadataStandardId' => elem.dig('metadata_standard_id', 'identifier'),
                'idType' => elem.dig('metadata_standard_id', 'type')
              }
            )
          end
          metadata_list
        end

        def convert_technical_ressource(facilities)
          return [] if facilities.nil?

          facilities_list = []
          facilities.each do |elem|
            facilities_list.append(
              {
                'description' => elem['description'],
                'title' => elem['title']
              }
            )
          end
          facilities_list
        end

        def convert_cost(costs)
          return [] if costs.nil?

          costs_list = []
          costs.each do |elem|
            costs_list.append(
              {
                'currency' => elem['currency_code'],
                'costType' => elem['description'],
                'title' => elem['title'],
                'amount' => elem['value']
              }
            )
          end
          costs_list
        end

        def convert_host(distributions)
          return [] if distributions.nil?

          hosts_list = []
          distributions.each do |elem|
            next if elem['host'].nil?

            hosts_list.append(
              {
                'availability' => elem.dig('host', 'availability'),
                'certification' => if elem.dig('host', 'certified_with').present?
                                     [elem.dig('host', 'certified_with')]
                                   end,
                'description' => elem.dig('host', 'description'),
                'geoLocation' => elem.dig('host', 'geo_location'),
                'pidSystem' => elem.dig('host', 'pid_system'),
                'hasVersioningPolicy' => elem.dig('host', 'support_versioning')&.capitalize,
                'title' => elem.dig('host', 'title'),
                'hostId' => elem.dig('host', 'url')
              }
            )
          end
          hosts_list
        end

        # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        def convert_distribution(distribution)
          return [] if distribution.nil?

          distributions_list = []
          distribution.each do |elem|
            license = elem['license'].present? ? elem['license'].first : {}
            distributions_list.append(
              {
                'releaseDate' => '',
                'accessUrl' => elem['access_url'],
                'availableUntil' => elem['available_until'],
                'fileVolume' => elem['byte_size'],
                'volumeUnit' => 'Bytes',
                'dataAccess' => elem['data_access'],
                'description' => elem['description'],
                'downloadUrl' => elem['download_url'],
                'fileFormat' => elem['format'].present? ? elem['format'].first : nil,
                'fileName' => elem['title'],
                'license' => {
                  'licenseUrl' => license['license_ref'].present? ? license['license_ref'].first : nil
                },
                'licenseStartDate' => license['start_date']
              }
            )
          end
          distributions_list
        end
        # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

        def convert_security_measures(security_info)
          return '' if security_info.blank?

          title = security_info.first['title']
          title.concat(' : ', security_info.first['description']) unless security_info.first['description'].nil?
          title
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def convert_research_output(research_output, full_dmp)
          ro_list = []
          # rubocop:disable Metrics/BlockLength
          research_output.each do |dataset|
            ro_list.append(
              {
                'documentationQuality' => {
                  'description' => if dataset['data_quality_assurance'].present?
                                     dataset['data_quality_assurance'].first
                                   end, # else nil in implied
                  'metadataStandard' => convert_metadata(dataset['metadata']),
                  'metadataLanguage' => dataset['metadata'].present? ? dataset['metadata'].first['language'] : nil
                },
                'researchOutputDescription' => {
                  'datasetId' => dataset.dig('dataset_id', 'identifier'),
                  'issuedDate' => dataset['issued'],
                  'idType' => dataset.dig('dataset_id', 'type'),
                  'description' => dataset['description'],
                  'uncontrolledKeywords' => [dataset['keyword']],
                  'language' => dataset['language'],
                  'containsPersonalData' => dataset['personal_data']&.capitalize,
                  'title' => dataset['title'],
                  'type' => dataset['type'],
                  'containsSensitiveData' => dataset['sensitive_data']&.capitalize,
                  'hasEthicalIssues' => full_dmp['ethical_issues_exist']&.capitalize
                },
                'sharing' => {
                  'distribution' => convert_distribution(dataset['distribution']),
                  'host' => convert_host(dataset['distribution'])
                },
                'preservationIssues' => {
                  'description' => dataset['preservation_statement']
                },
                'dataStorage' => {
                  'securityMeasures' => convert_security_measures(dataset['security_and_privacy'])
                },
                'ethicalIssues' => {
                  'description' => full_dmp['ethical_issues_description'],
                  'resourceReference' => [{
                    'docIdentifier' => full_dmp['ethical_issues_report']
                  }]
                },
                'dataCollection' => {
                  'facility' => convert_technical_ressource(dataset['technical_resource'])
                }
              }
            )
          end
          # rubocop:enable Metrics/BlockLength
          ro_list
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      end
    end
  end
end
