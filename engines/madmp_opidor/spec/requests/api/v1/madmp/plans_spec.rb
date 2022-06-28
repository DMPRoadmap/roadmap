# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/madmp/plans', type: :request do

  path '/api/v1/madmp/plans/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'Plan identifier'

    get('Export Plan in the Standard format') do
      tags 'Plans'
      produces 'application/json'
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/madmp/plans/{id}/rda_export' do
    parameter name: 'id', in: :path, type: :string, description: 'Plan indentifier'

    get('Export Plan in the RDA Common Standard format') do
      tags 'Plans'
      produces 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
        let(:id) { '123' }

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/madmp/plans/import' do
    parameter name: 'import_format',
              in: :query, type: :string,
              description: 'Import format (standard/rda)', default: 'standard'

    post('Import and create a new plan based on a Standard or RDA input format') do
      tags 'Plans'
      produces 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
        let(:import_format) { 'standard' }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end
        run_test!
      end
    end
  end
end
