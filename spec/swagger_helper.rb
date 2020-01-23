require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.swagger_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'

  # Commenting out `openapi: 3.0.1` because rswag does not yet support that
  # version which uses `requestBody` instead of `body` for POST/PUT endpoints!
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      swagger: '2.0', # openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      securityDefinitions: {
        bearerAuth: {
          type: :apiKey,
          description: "Bearer token",
          name: "Authorization",
          in: :header

        }
      },
      definitions: {
        dmp: {
          type: :object,
          properties: {
            title: { type: :string, example: "My research project" },
            description: { type: :string, example: "An abstract describing the project and the data we intend to collect" },
            created: { type: :string, example: Time.now.utc.to_s },
            modified: { type: :string, example: Time.now.utc.to_s },
            language: { type: :string, example: "en, es, de, etc." },
            ethical_issues: { type: :string, enum: %w[unknown yes no], example: "unknown" },
            ethical_issues_description: { type: :string, example: "An explanation of the types of ethical concerns our data may contain or deal with (e.g. 'We will anonymize patient data.')" },
            ethical_issues_report: { type: :string, example: "https://my.school.edu/path/to/a/report/on/ethics_and_privacy/statements.pdf" },
            dmp_id: { "$ref": "#/definitions/dmp_identifier" },
            contact: { "$ref": "#/definitions/contact" },
            contributor: {
              type: :array,
              items: { "$ref": "#/definitions/contributor" }
            },
            project: {
              type: :array,
              items: { "$ref": "#/definitions/project" }
            }
          },
          required: %w[title ethical_issues contact dataset]
        },
        dmp_identifier: {
          type: :object,
          properties: {
            type: {
              type: :string,
              description: "One of the following identifier types",
              enum: ["doi", "url" "#{ApplicationService.application_name.split("-").first}"],
              example: "doi"
            },
            identifier: { type: :string, example: "https://dx.doi.org/abc123" }
          },
          required: %w[type identifier]
        },
        person_identifier: {
          type: :object,
          properties: {
            type: {
              type: :string,
              description: "One of the following identifier types or the local identifier from your system.",
              enum: %w[orcid isni openid other]
            },
            identifier: { type: :string, example: "0000-0000-0000-0000" }
          },
          required: %w[type identifier]
        },
        organization_identifier: {
          type: :object,
          properties: {
            type: {
              type: :string,
              description: "One of the following identifier types or the local identifier from your system.",
              enum: %w[ror fundref]
            },
            identifier: { type: :string, example: "https://ror.org/x123y12z" }
          },
          required: %w[type identifier]
        },
        contact: {
          type: :object,
          properties: {
            name: { type: :string, example: "Jane Doe" },
            mbox: { type: :string, example: "jane.doe@nowhere.edu" },
            affiliation: { "$ref": "#/definitions/affiliation" },
            contact_id: { "$ref": "#/definitions/person_identifier" }
          },
          required: %w[name mbox]
        },
        contributor: {
          type: :object,
          properties: {
            name: { type: :string, example: "Jane Doe" },
            mbox: { type: :string, example: "jane.doe@nowhere.edu" },
            role: {
              type: :string,
              enum: [
                Contributor.new.all_roles.map do |r|
                  "#{Contributor::ONTOLOGY_BASE_URL}/#{r.to_s.capitalize}"
                end
              ],
              example: "#{Contributor::ONTOLOGY_BASE_URL}/#{Contributor.new.all_roles.first.to_s.capitalize}"
            },
            affiliation: { "$ref": "#/definitions/affiliation" },
            contributor_id: { "$ref": "#/definitions/person_identifier" }
          },
          required: %w[name mbox role]
        },
        affiliation: {
          type: :object,
          properties: {
            name: { type: :string, example: "University of Nowhere" },
            abbreviation: { type: :string, example: "UN" },
            region: { type: :string, example: "United States" },
            affiliation_id: { "$ref": "#/definitions/organization_identifier" }
          },
          required: %w[name]
        },
        project: {
          type: :object,
          properties: {
            title: { type: :string, example: "Study of API development in open source codebases" },
            description: { type: :string, example: "An abstract describing the overall research project" },
            start: { type: :string, example: (Time.now + 3.months).utc.to_s },
            end: { type: :string, example: (Time.now + 38.months).utc.to_s },
            funding: {
              type: :array,
              items: { "$ref": "#/definitions/funding" }
            }
          },
          required: %w[title start end]
        },
        funding: {
          type: :object,
          properties: {
            name: { type: :string, example: "National Science Foundation" },
            funding_status: { type: :string, enum: %w[planned applied granted rejected], example: "granted" },
            funder_id: { "$ref": "#/definitions/organization_identifier" },
            grant_id: {
              type: :object,
              properties: {
                type: {
                  type: :string,
                  enum: %w[url other]
                },
                identifier: { type: :string, example: "https://funder.org/999" }
              },
              required: %w[type identifier]
            }
          },
          required: %w[name funding_status grant_id]
        },
        dataset: {
          type: :object,
          properties: {
            title: { type: :string, example: "Time lapse video of bacteria riding a bicycle" },
            dataset_id: {
              type: :object,
              properties: {
                type: {
                  type: :string,
                  enum: %w[ark doi handle url other],
                  example: "doi"
                },
                identifier: { type: :string, example: "doi:10.9999/123ab/c453" }
              }
            },
            personal_data: { type: :string, enum: %w[unknown yes no], example: "unknown" },
            sensitive_data: { type: :string, enum: %w[unknown yes no], example: "unknown" }
          },
          required: %w[title dataset_id personal_data sensitive_data]
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The swagger_docs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.swagger_format = :yaml
end
