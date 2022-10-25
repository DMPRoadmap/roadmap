# frozen_string_literal: true

require 'rails_helper'

describe 'api/v2/templates/index.json.jbuilder' do
  before do
    @application = Faker::Lorem.word
    @url = Faker::Internet.url
    @code = [200, 400, 404, 500].sample

    @template1 = create(:template, :published, org: create(:org), phases: 1)
    @template2 = create(:template, :published)

    assign :application, @application
    assign :items, [@template1, @template2]

    @resp = OpenStruct.new(status: @code)
    @req = Net::HTTPGenericRequest.new('GET', nil, nil, @url)
  end

  describe 'includes all of the Template attributes' do
    before do
      render template: 'api/v2/templates/index',
             locals: { response: @resp, request: @req }
      @json = JSON.parse(rendered).with_indifferent_access

      @template = @json[:items].first[:dmp_template]
    end

    it 'includes both templates' do
      expect(@json[:items].length).to be(2)
    end

    it 'includes the :title' do
      expect(@template[:title]).to eql(@template1.title)
    end

    it 'includes the :description' do
      expect(@template[:description]).to eql(@template1.description)
    end

    it 'includes the :version' do
      expect(@template[:version]).to eql(@template1.version)
    end

    it 'includes the :created' do
      expect(@template[:created]).to eql(@template1.created_at.to_formatted_s(:iso8601))
    end

    it 'includes the :modified' do
      expect(@template[:modified]).to eql(@template1.updated_at.to_formatted_s(:iso8601))
    end

    it 'includes the :affiliation' do
      expect(@template[:affiliation][:name]).to eql(@template1.org.name)
    end

    it 'includes the :template_ids' do
      expect(@template[:template_id][:identifier]).to eql(@template1.family_id.to_s)
      expect(@template[:template_id][:type]).to eql('other')
    end

    # The show_url parameter is either false or not included
    it 'includes the :phases' do
      expect(@json[:items].first[:dmp_template][:phases]).to be_nil
    end
  end

  # The show_url parameter is true
  describe 'when the show_phases url parameter is true' do
    before do
      @show_phases = true
      render template: 'api/v2/templates/index',
             locals: { response: @resp, request: @req, show_phases: @show_phases }
      @json = JSON.parse(rendered).with_indifferent_access
    end

    it 'returns the :phases' do
      expect(@json[:items].first[:dmp_template][:phases].length).to be(1)
    end
  end
end
