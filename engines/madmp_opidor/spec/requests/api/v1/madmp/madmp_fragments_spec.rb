# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'api/v1/madmp/madmp_fragments', type: :request do
  path '/api/v1/madmp/dmp_fragments/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'Root JSON fragment identifier'

    get('Get a list of all the JSON fragment of a DMP') do
      tags 'MadmpFragments'
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

  path '/api/v1/madmp/fragments/{id}' do
    # You'll want to customize the parameter types...
    parameter name: 'id', in: :path, type: :string, description: 'JSON fragment identifier'

    get('Get a JSON fragment') do
      tags 'MadmpFragments'
      produces 'application/json'
      security [Bearer: []]
      parameter name: 'mode',
                in: :query,
                type: :string,
                description: 'JSON fragment export mode (fat/slim)',
                default: 'slim',
                enum: %w[slim fat]

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

    patch('Update a JSON fragment') do
      tags 'MadmpFragments'
      produces 'application/json'
      consumes 'application/json'
      security [Bearer: []]
      parameter name: :data, in: :body, schema: {
        type: :object
      }

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

    put('Update a JSON fragment') do
      tags 'MadmpFragments'
      produces 'application/json'
      consumes 'application/json'
      security [Bearer: []]
      parameter name: :data, in: :body, schema: {
        type: :object
      }

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
