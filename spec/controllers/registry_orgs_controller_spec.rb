# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistryOrgsController, type: :controller do

  before(:each) do
    @controller = RegistryOrgsController.new
  end

  describe "GET orgs/search" do
    before(:each) do
      @org = create(:org, name: Faker::Music::PearlJam.album)
      @registry_org = create(:registry_org, name: "The new #{@org.name} (music.org)")
      @hash = { org_autocomplete: { name: @org.name } }
    end

    it "returns an empty array if the search term is missing" do
      post :search, params: { org_autocomplete: { id: "Fo" } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it "returns an empty array if the search term is blank" do
      post :search, params: { org_autocomplete: { name: "" } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it "returns an empty array if the search term is less than 3 characters" do
      post :search, params: { org_autocomplete: { name: "Fo" } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it "calls the :find_by_search_term method" do
      @controller.stubs(:find_by_search_term).returns([@org.name])
      post :search, params: { org_autocomplete: { name: @org } }, format: :js
      json = JSON.parse(response.body)
      expect(json.length).to eql(1)
      expect(json.first).to eql(@org.name)
    end
  end

  context "private methods" do
    describe ":find_by_search_term(term:, **options)" do
      it "returns an empty array if no term is present" do

      end
    end

    describe ":orgs_search(term:, **options)" do

    end

    describe ":registry_orgs_search(term:, **options)" do

    end

    describe ":sort_search_results(results:, term:)" do

    end

    describe ":weigh(term:, org:)" do

    end
  end
end
