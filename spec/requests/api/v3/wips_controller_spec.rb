# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V3::WipsController do
  include Helpers::ApiHelper

  let!(:admin) { create(:user, :org_admin) }
  let!(:headers) do
    {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  end

  before do
    sign_in(admin)
  end

  describe 'GET /dmps' do
    it 'returns an empty :items if the user has no wips' do
      get(api_v3_wips_path, headers: headers)
      expect(response.code).to eql('200')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).with_indifferent_access
      expect(json[:items].empty?).to be(true)
      expect(json[:errors].nil?).to be(true)
    end

    it 'returns the expected wips' do
      admin2 = create(:user, :org_admin)
      wip1 = create(:wip, user: admin)
      wip2 = create(:wip, user: admin)
      wip3 = create(:wip, user: admin2)

      get(api_v3_wips_path, headers: headers)
      expect(response.code).to eql('200')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).fetch('items', [])
      expect(json.length).to eql(2)
      expect(json.include?(JSON.parse(wip1.to_json))).to be(true)
      expect(json.include?(JSON.parse(wip2.to_json))).to be(true)
      expect(json.include?(JSON.parse(wip3.to_json))).to be(false)
    end
  end

  describe 'POST /dmps' do
    it 'fails if the wip is not JSON' do
      post(api_v3_wips_path, headers: headers, params: '1234')

      expect(response.code).to eql('400')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql("Invalid request #{Wip::INVALID_JSON_MSG}")
    end

    it 'fails if the wip is not valid JSON' do
      wip = build(:wip, metadata: { foo: 'bar' })
      post(api_v3_wips_path, headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('400')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql("Invalid request #{Wip::INVALID_JSON_MSG}")
    end

    it 'succeeds and returns the wip with it\'s new identifier' do
      wip = build(:wip, metadata: { dmp: { title: Faker::Music::GratefulDead.song, description: Faker::Lorem.sentence } })
      post(api_v3_wips_path, headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('201')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:items, [])
      expect(json.length).to eql(1)
      expect(json.first['dmp']['title']).to eql(wip.metadata['dmp']['title'])
      expect(json.first['dmp']['description']).to eql(wip.metadata['dmp']['description'])
      expect(json.first['dmp']['wip_id']['type']).to eql('other')
      expect(json.first['dmp']['wip_id']['identifier'].present?).to be(true)
    end
  end

  describe 'GET /dmps/{:identifier}' do
    let!(:wip) { create(:wip, user: admin, metadata: { dmp: { title: Faker::Music::GratefulDead.song } }) }

    it 'fails if the wip is not found' do
      other_wip = build(:wip, user: admin, metadata: { dmp: { title: Faker::Music::PearlJam.song } })
      get(api_v3_wip_path('foo-123456789'), headers: headers, params: JSON.parse(other_wip.to_json))

      expect(response.code).to eql('404')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql(Api::V3::WipsController::MSG_WIP_NOT_FOUND)
    end

    it 'fails if the wip does not belong to the current user' do
      other_wip = create(:wip, user: create(:user, :super_admin), metadata: { dmp: { title: 'foo' } })
      get(api_v3_wip_path(other_wip.identifier), headers: headers, params: JSON.parse(other_wip.to_json))

      expect(response.code).to eql('401')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql(Api::V3::WipsController::MSG_WIP_UNAUTHORIZED)
    end

    it 'succeeds and returns the wip' do
      get(api_v3_wip_path(wip.identifier), headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('200')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:items, [])
      expect(json.length).to eql(1)
      expect(json.first['dmp']['title']).to eql(wip.metadata['dmp']['title'])
      expect(json.first['dmp']['description']).to eql(wip.metadata['dmp']['description'])
      expect(json.first['dmp']['wip_id']['type']).to eql('other')
      expect(json.first['dmp']['wip_id']['identifier']).to eql(wip.identifier)
    end
  end

  describe 'PUT /dmps/{:identifier}' do
    let!(:wip) { create(:wip, user: admin, metadata: { dmp: { title: Faker::Music::GratefulDead.song } }) }

    it 'fails if the wip is not JSON' do
      put(api_v3_wip_path(wip.identifier), headers: headers, params: '1234')

      expect(response.code).to eql('400')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql("Invalid request #{Wip::INVALID_JSON_MSG}")
    end

    it 'fails if the wip is not valid JSON' do
      wip.metadata['dmp'].delete('title')
      put(api_v3_wip_path(wip.identifier), headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('400')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql("Invalid request #{Wip::INVALID_JSON_MSG}")
    end

    it 'fails if the wip is not found' do
      other_wip = build(:wip, user: admin, metadata: { dmp: { title: Faker::Music::PearlJam.song } })
      put(api_v3_wip_path('foo-123456789'), headers: headers, params: JSON.parse(other_wip.to_json))

      expect(response.code).to eql('404')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql(Api::V3::WipsController::MSG_WIP_NOT_FOUND)
    end

    it 'fails if the wip does not belong to the current user' do
      other_wip = create(:wip, user: create(:user, :super_admin), metadata: { dmp: { title: 'foo' } })
      put(api_v3_wip_path(other_wip.identifier), headers: headers, params: JSON.parse(other_wip.to_json))

      expect(response.code).to eql('401')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql(Api::V3::WipsController::MSG_WIP_UNAUTHORIZED)
    end

    it 'succeeds and skips unknown wip components' do
      wip.metadata['dmp']['foo'] = 'bar'
      put(api_v3_wip_path(wip.identifier), headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('200')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:items, [])
      expect(json.length).to eql(1)
      expect(json.first['dmp']['title']).to eql(wip.metadata['dmp']['title'])
      expect(json.first['dmp']['foo'].present?).to be(false)
      expect(json.first['dmp']['wip_id']['type']).to eql('other')
      expect(json.first['dmp']['wip_id']['identifier']).to eql(wip.identifier)

    end

    it 'succeeds and returns the wip with it\'s new identifier' do
      wip.metadata['dmp']['project'] = [{ 'start': '2023-06-01T11:47:34+3', funding: [{ name: Faker::Company.name }] }]
      put(api_v3_wip_path(wip.identifier), headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('200')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:items, [])
      expect(json.length).to eql(1)
      expect(json.first['dmp']['title']).to eql(wip.metadata['dmp']['title'])
      expected = wip.metadata['dmp']['project'].first[:funding].first[:name]
      expect(json.first['dmp']['project'].first['funding'].first['name']).to eql(expected)
      expect(json.first['dmp']['wip_id']['type']).to eql('other')
      expect(json.first['dmp']['wip_id']['identifier']).to eql(wip.identifier)
    end
  end

  describe 'DELETE /dmps/{:identifier}' do
    let!(:wip) { create(:wip, user: admin, metadata: { dmp: { title: Faker::Music::GratefulDead.song } }) }

    it 'fails if the wip is not found' do
      other_wip = build(:wip, user: admin, metadata: { dmp: { title: Faker::Music::PearlJam.song } })
      delete(api_v3_wip_path('foo-123456789'), headers: headers, params: JSON.parse(other_wip.to_json))

      expect(response.code).to eql('404')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql(Api::V3::WipsController::MSG_WIP_NOT_FOUND)
    end

    it 'fails if the wip does not belong to the current user' do
      other_wip = create(:wip, user: create(:user, :super_admin), metadata: { dmp: { title: 'foo' } })
      delete(api_v3_wip_path(other_wip.identifier), headers: headers, params: JSON.parse(other_wip.to_json))

      expect(response.code).to eql('401')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/error')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:errors, [])
      expect(json.length).to eql(1)
      expect(json.first).to eql(Api::V3::WipsController::MSG_WIP_UNAUTHORIZED)
    end

    it 'succeeds and deletes the wip' do
      delete(api_v3_wip_path(wip.identifier), headers: headers, params: JSON.parse(wip.to_json))

      expect(response.code).to eql('200')
      expect(response).to render_template('api/v3/_standard_response')
      expect(response).to render_template('api/v3/wips/index')

      json = JSON.parse(response.body).with_indifferent_access.fetch(:items, [])
      expect(json.length).to eql(0)
    end
  end
end
