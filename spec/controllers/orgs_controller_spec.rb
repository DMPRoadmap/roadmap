# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgsController, type: :controller do

  before(:each) do
    uri = URI.parse(Faker::Internet.url)
    @name = Faker::Company.name

    OrgSelectionService.stubs(:search).returns([{
      id: uri.to_s,
      name: "#{@name} (#{uri.host})",
      sort_name: @name,
      score: 0,
      weight: 1
    }])
  end

  describe "POST /search" do

    it "returns an empty array if the search term is blank" do
      post :search, org: { name: "" }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it "returns an empty array if the search term is less than 3 characters" do
      post :search, org: { name: "Fo" }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it 'assigns the orgs variable' do
      post :search, org: { name: Faker::Lorem.sentence }, format: :js
      json = JSON.parse(response.body)
      expect(json.length).to eql(1)
      expect(json.first["sort_name"]).to eql(@name)
    end

  end

end
