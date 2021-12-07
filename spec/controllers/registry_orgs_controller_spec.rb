# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistryOrgsController, type: :controller do
  before(:each) do
    @controller = RegistryOrgsController.new

    @org = create(:org, name: Faker::Music::PearlJam.album)
    @registry_org = create(:registry_org, name: "#{@org.name} (music.org)")
  end

  describe 'GET orgs/search' do
    it 'returns an empty array if the search term is missing' do
      post :search, params: { org_autocomplete: { id: 'Fo' } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it 'returns an empty array if the search term is blank' do
      post :search, params: { org_autocomplete: { name: '' } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it 'returns an empty array if the search term is less than 3 characters' do
      post :search, params: { org_autocomplete: { name: 'Fo' } }, format: :js
      expect(JSON.parse(response.body)).to eql([])
    end

    it 'calls the :find_by_search_term method' do
      @controller.stubs(:find_by_search_term).returns([@org.name])
      post :search, params: { org_autocomplete: { name: @org.name[0..@org.name.length - 2] } }, format: :js
      json = JSON.parse(response.body)
      expect(json.length).to eql(1)
      expect(json.first).to eql(@org.name)
    end
  end

  context 'private methods' do
    describe ':find_by_search_term(term:, **options)' do
      it 'returns an empty array if no term is present' do
        expect(@controller.send(:find_by_search_term, term: nil)).to eql([])
      end
      it 'it obeys the `restrict_orgs` config setting if :known_only is not specified' do
        hash = {
          term: @org.name, managed_only: nil, funder_only: nil, non_funder_only: nil, known_only: nil
        }
        Rails.configuration.x.application.restrict_orgs = true
        hash[:known_only] = true
        @controller.expects(:registry_orgs_search).with(hash).returns([@registry_org])
        @controller.send(:find_by_search_term, term: @org.name)

        Rails.configuration.x.application.restrict_orgs = false
        hash[:known_only] = false
        @controller.expects(:registry_orgs_search).with(hash).returns([@registry_org])
        @controller.send(:find_by_search_term, term: @org.name)
      end
      it 'it calls :registry_orgs_search, :orgs_search and :sort_search_results' do
        @controller.expects(:registry_orgs_search).returns([@registry_org])
        @controller.expects(:orgs_search).returns([@org])
        @controller.expects(:sort_search_results).with(term: @org.name, results: [@registry_org, @org])
        @controller.send(:find_by_search_term, term: @org.name)
      end
    end

    describe ':orgs_search(term:, **options)' do
      it 'calls Org.search' do
        Org.expects(:search).with(@org.name).returns([])
        @controller.send(:orgs_search, term: @org.name)
      end
      it 'does not return orgs who have an association in the registry_orgs table' do
        associated_org = create(:org)
        results = @controller.send(:orgs_search, term: associated_org.name)
        expect(results.include?(associated_org)).to eql(false)
      end
      it 'uses correct default flags' do
        # :managed_only should default to false
        @org.update(managed: false)
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to eql(true)

        # :funder_only should default to false
        @org.update(managed: true, funder: false)
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to eql(true)

        # :non_funder_only should default to false
        @org.update(managed: true, funder: true)
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to eql(true)
      end
      it 'obeys the :managed_only flag' do
        @org.update(managed: false)
        results = @controller.send(:orgs_search, term: @org.name, managed_only: true)
        expect(results.include?(@org)).to eql(false)
      end
      it 'obeys the :funder_only flag' do
        @org.update(funder: false)
        results = @controller.send(:orgs_search, term: @org.name, funder_only: true)
        expect(results.include?(@org)).to eql(false)
      end
      it 'obeys the :non_funder_only flag' do
        @org.update(funder: true)
        results = @controller.send(:orgs_search, term: @org.name, non_funder_only: true)
        expect(results.include?(@org)).to eql(false)
      end
      it 'returns the expected results' do
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to eql(true)
      end
    end

    describe ':registry_orgs_search(term:, **options)' do
      before(:each) do
        @registry_org.update(org_id: @org.id)
      end

      it 'calls RegistryOrg.search' do
        RegistryOrg.expects(:search).with(@org.name).returns([])
        @controller.send(:registry_orgs_search, term: @org.name)
      end
      it 'uses correct default flags' do
        # :managed_only should default to false
        @org.update(managed: false)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to eql(true)

        # :known_only should default to false
        @registry_org.update(org_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to eql(true)

        # :funder_only should default to false
        @registry_org.update(fundref_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to eql(true)

        # :non_funder_only should default to false
        @registry_org.update(fundref_id: Faker::Internet.url)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to eql(true)
      end
      it 'obeys the :known_only flag' do
        @registry_org.update(org_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name, known_only: true)
        expect(results.include?(@registry_org)).to eql(false)
      end
      it 'obeys the :funder_only flag' do
        @registry_org.update(fundref_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name, funder_only: true)
        expect(results.include?(@registry_org)).to eql(false)
      end
      it 'obeys the :non_funder_only flag' do
        @registry_org.update(fundref_id: Faker::Internet.url)
        results = @controller.send(:registry_orgs_search, term: @org.name, non_funder_only: true)
        expect(results.include?(@registry_org)).to eql(false)
      end
      it 'obeys the :managed_only flag' do
        @org.update(managed: false)
        results = @controller.send(:registry_orgs_search, term: @org.name, managed_only: true)
        expect(results.include?(@registry_org)).to eql(false)
      end
      it 'returns the expected results' do
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to eql(true)
      end
    end

    describe ':sort_search_results(results:, term:)' do
      before(:each) do
        @other_registry_org = create(:registry_org, name: "another one like #{@org.name}")
      end
      it 'returns an empty array if results is not present' do
        expect(@controller.send(:sort_search_results, results: nil, term: @org.name))
      end
      it 'returns an empty array if results is empty' do
        expect(@controller.send(:sort_search_results, results: [], term: @org.name))
      end
      it 'returns an empty array if term is not present' do
        expect(@controller.send(:sort_search_results, results: [@org], term: nil))
      end
      it 'calls :weigh for each result' do
        @controller.expects(:weigh).twice
        @controller.send(:sort_search_results, results: [@org, @registry_org], term: @org.name)
      end
      it 'sorts the results by weight and name' do
        @controller.expects(:weigh).with(term: @org.name, org: @registry_org).returns(3)
        @controller.expects(:weigh).with(term: @org.name, org: @other_registry_org).returns(1)
        results = @controller.send(:sort_search_results, results: [@other_registry_org, @registry_org],
                                                         term: @org.name)
        expect(results.length).to eql(2)
        expect(results.first).to eql(@registry_org.name)
        expect(results.last).to eql(@other_registry_org.name)
      end
      it 'returns the names of the orgs only' do
        results = @controller.send(:sort_search_results, results: [@other_registry_org, @registry_org],
                                                         term: @org.name)
        expect(results.include?(@registry_org.name)).to eql(true)
        expect(results.include?(@other_registry_org.name)).to eql(true)
      end
    end

    describe ':weigh(term:, org:)' do
      before(:each) do
        @term = Faker::Music::PearlJam.song.gsub(' ', '-').upcase
        # Make sure the names do not include the search term so we can control scenarios
        @org.name = Faker::Lorem.sentence.gsub(@term, '')
        @registry_org.name = Faker::Lorem.sentence.gsub(@term, '')
      end
      it 'returns 0 if :term is not present?' do
        expect(@controller.send(:weigh, term: nil, org: @org)).to eql(0)
      end
      it 'returns 0 if :org is not an Org or RegistryOrg' do
        expect(@controller.send(:weigh, term: @term, org: 'Foo')).to eql(0)
      end
      it 'returns 1 if all we could match is on the RegistryOrg acronym' do
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to eql(1)
      end
      it 'returns 1 if all we could match is on the Org abbreviation' do
        @org.abbreviation = @term
        expect(@controller.send(:weigh, term: @term, org: @org)).to eql(1)
      end
      it 'returns 2 if all we could determine is that the name starts with the term' do
        @org.name = "#{@term} - #{@org.name}"
        expect(@controller.send(:weigh, term: @term, org: @org)).to eql(2)
      end
      it 'returns 1 if all we could determine was that the RegistryOrg has an :org_id' do
        @registry_org.org_id = @org.id
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to eql(1)
      end
      it 'returns 1 if all we could determine was that the name includes the term (not start_with)' do
        @org.name = "#{@org.name} (#{@term})"
        expect(@controller.send(:weigh, term: @term, org: @org)).to eql(1)
      end
      it 'returns 3 if name starts with the :term, the RegistryOrg has an :org_id' do
        @registry_org.org_id = @org.id
        @registry_org.name = "#{@term} - #{@org.name}"
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to eql(3)
      end
      it 'returns 3 if name starts with the :term, the Org :abbreviation matches' do
        @org.abbreviation = @term
        @registry_org.name = "#{@term} - #{@org.name}"
        expect(@controller.send(:weigh, term: @term, org: @org)).to eql(1)
      end
      it 'returns 4 if name starts with the :term, the :acronym matches, the RegistryOrg has an :org_id' do
        @registry_org.org_id = @org.id
        @registry_org.name = "#{@term} - #{@org.name}"
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to eql(4)
      end
      it 'returns 2 if the RegistryOrg :acronym matches and the :org_id is present' do
        @registry_org.org_id = @org.id
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to eql(2)
      end
      it 'returns 2 if the :acronym matches and the :name includes the :term' do
        @registry_org.name = "#{@org.name} (#{@term})"
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to eql(2)
      end
      it 'returns 2 if the :abbreviation matches and the :name includes the :term' do
        @org.name = "#{@org.name} (#{@term})"
        @org.abbreviation = @term
        expect(@controller.send(:weigh, term: @term, org: @org)).to eql(2)
      end
    end
  end
end
