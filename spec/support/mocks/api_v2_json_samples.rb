# frozen_string_literal: true

# Mock JSON submissions
module Mocks

  # Disabling rubocop checks here since its basically just large hashes and
  # would be difficult to read if broken up into multiple smaller functions.
  # One option might be to store them as .json files and then just load them here
  # but we would lose the use of Faker

  # rubocop:disable Metrics/ModuleLength, Metrics/MethodLength
  module ApiV2JsonSamples

    ROLES = %w[Investigation Project_administration Data_curation].freeze

    def mock_identifier_schemes
      create(:identifier_scheme, name: "ror")
      create(:identifier_scheme, name: "fundref")
      create(:identifier_scheme, name: "orcid")
      create(:identifier_scheme, name: "grant")
    end

    def minimal_update_json
      {
        "total_items": 1,
        "items": [
          {
            "dmp": {
              "title": Faker::Lorem.sentence,
              "contact": {
                "mbox": Faker::Internet.email,
                "affiliation": { "name": Faker::Movies::StarWars.planet }
              },
              "dataset": [{
                "title": Faker::Lorem.sentence
              }],
              "dmp_id": {
                "type": "doi",
                "identifier": SecureRandom.uuid
              }
            }
          }
        ]
      }.to_json
    end

    def minimal_create_json
      {
        "dmp": {
          "title": Faker::Lorem.sentence,
          "contact": {
            "mbox": Faker::Internet.email,
            "affiliation": { "name": Faker::Movies::StarWars.planet }
          },
          "dataset": [{
            "title": Faker::Lorem.sentence
          }],
          "extension": [
            "#{ApplicationService.application_name.split("-").first}": {
              "template": {
                "id": Template.last.id,
                "title": Faker::Lorem.sentence
              }
            }
          ]
        }
      }.to_json
    end

    # rubocop:disable Metrics/AbcSize
    def complete_create_json(client: nil)
      create(:template) unless Template.all.any?
      lang = Language.all.pluck(:abbreviation).sample || "en-UK"
      ror_scheme = IdentifierScheme.find_or_create_by(name: "ror")
      fundref_scheme = IdentifierScheme.find_or_create_by(name: "fundref")
      ror = create(:identifier, identifiable: create(:org), identifier_scheme: ror_scheme)
      fundref = create(:identifier, identifiable: create(:org), identifier_scheme: fundref_scheme)

      contact = {
        name: [
          Faker::TvShows::Simpsons.character.split(" ").first,
          Faker::TvShows::Simpsons.character.split(" ").last
        ].join(" "),
        email: Faker::Internet.email,
        id: SecureRandom.uuid
      }

      {
        "dmp": {
          "created": (Time.now - 3.months).to_formatted_s(:iso8601),
          "title": Faker::Lorem.sentence,
          "description": Faker::Lorem.paragraph,
          "language": Api::V1::LanguagePresenter.three_char_code(lang: lang),
          "ethical_issues_exist": %w[yes no unknown].sample,
          "ethical_issues_description": Faker::Lorem.paragraph,
          "ethical_issues_report": Faker::Internet.url,
          "dmp_id": {
            "type": client.present? ? client.name.downcase : "other",
            "identifier": SecureRandom.uuid
          },
          "contact": {
            "name": contact[:name],
            "mbox": contact[:email],
            "affiliation": {
              "name": ror.identifiable.name,
              "abbreviation": Faker::Lorem.word.upcase,
              "region": Faker::Space.planet,
              "affiliation_id": {
                "type": "ror",
                "identifier": ror.value
              }
            },
            "contact_id": {
              "type": "orcid",
              "identifier": contact[:id]
            }
          },
          "contributor": [{
            "role": [
              "http://credit.niso.org/contributor-roles/project-administration",
              "http://credit.niso.org/contributor-roles/investigation",
              "other"
            ],
            "name": Faker::Movies::StarWars.character,
            "mbox": Faker::Internet.email,
            "affiliation": {
              "name": Faker::Movies::StarWars.planet,
              "abbreviation": Faker::Lorem.word.upcase,
              "affiliation_id": {
                "type": "ror",
                "identifier": SecureRandom.uuid
              }
            },
            "contributor_id": {
              "type": "orcid",
              "identifier": SecureRandom.uuid
            }
          }, {
            "role": [
              "http://credit.niso.org/contributor-roles/investigation"
            ],
            "name": contact[:name],
            "mbox": contact[:email],
            "affiliation": {
              "name": ror.identifiable.name,
              "abbreviation": Faker::Lorem.word.upcase,
              "affiliation_id": {
                "type": "ror",
                "identifier": ror.value
              }
            },
            "contributor_id": {
              "type": "orcid",
              "identifier": contact[:id]
            }
          }],
          "project": [{
            "title": Faker::Lorem.sentence,
            "description": Faker::Lorem.paragraph,
            "start": (Time.now + 3.months).to_formatted_s(:iso8601),
            "end": (Time.now + 2.years).to_formatted_s(:iso8601),
            "funding": [{
              "name": fundref.identifiable.name,
              "funder_id": {
                "type": "fundref",
                "identifier": fundref.value
              },
              "grant_id": {
                "type": "other",
                "identifier": SecureRandom.uuid
              },
              "dmproadmap_funding_opportunity_id": {
                "type": "other",
                "identifier": SecureRandom.uuid
              },
              "funding_status": %w[planned rejected granted].sample
            }]
          }],
          "dataset": [{
            "title": Faker::Lorem.sentence,
            "description": Faker::Lorem.paragraph,
            "personal_data": %w[yes no unknown].sample,
            "sensitive_data": %w[yes no unknown].sample,
            "issued": (Time.now + 6.months).to_formatted_s(:iso8601),
            "dataset_id": {
              "type": "url",
              "identifier": Faker::Internet.url
            },
            "distribution": [{
              "title": Faker::Lorem.sentence,
              "byte_size": Faker::Number.number(digits: 6),
              "data_access": %w[open embargoed restricted closed].sample,
              "host": {
                "title": Faker::Company.name,
                "description": Faker::Lorem.paragraph,
                "url": Faker::Internet.url,
                "dmproadmap_host_id": {
                  "type": "url",
                  "identifier": Faker::Internet.url
                }
              },
              "license": [
                {
                  "license_ref": "http://spdx.org/licenses/CC0-1.0.json",
                  "start_date": (Time.now + 6.months).to_formatted_s(:iso8601)
                }
              ]
            }]
          }],
          "dmproadmap_template": { "id": Template.last.id, "title": Faker::Lorem.sentence }
        }
      }.to_json
    end
    # rubocop:enable Metrics/AbcSize

  end
  # rubocop:enable Metrics/ModuleLength, Metrics/MethodLength

end
