# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrgsController, type: :controller do

  before(:each) do
    uri = URI.parse(Faker::Internet.url)
    @name = Faker::Company.name

    hash = {
      id: uri.to_s,
      name: "#{@name} (#{uri.host})",
      sort_name: @name,
      score: 0,
      weight: 1
    }
    OrgSelection::SearchService.stubs(:search_locally).returns([hash])
    OrgSelection::SearchService.stubs(:search_externally).returns([hash])
    OrgSelection::SearchService.stubs(:search_combined).returns([hash])
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

    it "calls search_locally by default" do
      OrgSelection::SearchService.expects(:search_locally).at_least(1)
      post :search, org: { name: Faker::Lorem.sentence }, format: :js
    end

    it "calls search_externally when query string contains type=external" do
      OrgSelection::SearchService.expects(:search_externally).at_least(1)
      post :search, org: { name: Faker::Lorem.sentence }, type: "external",
                    format: :js
    end

    it "calls search_combined when query string contains type=combined" do
      OrgSelection::SearchService.expects(:search_combined).at_least(1)
      post :search, org: { name: Faker::Lorem.sentence }, type: "combined",
                    format: :js
    end
  end

end
