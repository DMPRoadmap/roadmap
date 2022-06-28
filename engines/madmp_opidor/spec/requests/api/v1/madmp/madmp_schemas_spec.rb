# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/madmp/madmp_schemas', type: :request do
  path '/api/v1/madmp/schemas' do
    get('List available Structured Forms Schemas') do
      tags 'MadmpSchemas'
      produces 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
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

  path '/api/v1/madmp/schemas/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :integer, description: 'Schema identifier'

    get('Get a specific Structured Forms Schemas from its id') do
      tags 'MadmpSchemas'
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
end
