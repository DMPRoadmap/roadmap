# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/madmp/registries', type: :request do
  path '/api/v1/madmp/registries' do
    get('List available registries') do
      tags 'Registries'
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
      response(401, 'unauthorized') do
        run_test!
      end
    end
  end

  path '/api/v1/madmp/registries/{name}' do
    # You'll want to customize the parameter types...
    parameter name: 'name', in: :path, type: :string, description: 'Name of the registry'

    get('Get a specific registry from its name') do
      tags 'Registries'
      produces 'application/json'
      security [Bearer: []]
      response(200, 'successful') do
        let(:name) { '123' }

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
