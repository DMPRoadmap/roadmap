# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistryOrgsController do
  before do
    @controller = described_class.new

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
      post :search, params: { org_autocomplete: { name: @org.name[0..@org.name.length - 1] } }, format: :js
      json = JSON.parse(response.body)
      expect(json.length).to be(1)
      expect(json.first).to eql(@org.name)
    end
  end

  context 'private methods' do
    describe ':find_by_search_term(term:, **options)' do
      it 'returns an empty array if no term is present' do
        expect(@controller.send(:find_by_search_term, term: nil)).to eql([])
      end

      it 'obeys the `restrict_orgs` config setting if :known_only is not specified' do
        hash = {
          term: @org.name, known_only: nil, unknown_only: nil, managed_only: nil, funder_only: nil,
          template_owner_only: nil, non_funder_only: nil
        }
        Rails.configuration.x.application.restrict_orgs = true
        hash[:known_only] = true
        @controller.expects(:registry_orgs_search).with(**hash).returns([@registry_org])
        @controller.send(:find_by_search_term, term: @org.name)

        Rails.configuration.x.application.restrict_orgs = false
        hash[:known_only] = false
        @controller.expects(:registry_orgs_search).with(**hash).returns([@registry_org])
        @controller.send(:find_by_search_term, term: @org.name)
      end

      it 'calls :registry_orgs_search, :orgs_search and :deduplicate' do
        @controller.expects(:registry_orgs_search).returns([@registry_org])
        @controller.expects(:orgs_search).returns([@org])
        @controller.expects(:deduplicate).returns([@registry_org, @org])
        @controller.send(:find_by_search_term, term: @org.name)
      end

      it 'does not return orgs who have an association in the registry_orgs table' do
        @registry_org.update(org_id: @org.id)
        results = @controller.send(:find_by_search_term, term: @org.name)
        expect(results.include?(@registry_org)).to be(false)
      end
    end

    describe ':orgs_search(term:, **options)' do
      it 'calls Org.search' do
        Org.expects(:search).with(@org.name).returns([])
        @controller.send(:orgs_search, term: @org.name)
      end

      it 'uses correct default flags' do
        # :managed_only should default to false
        @org.update(managed: false)
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to be(true)

        # :funder_only should default to false
        @org.update(managed: true, funder: false)
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to be(true)

        # :non_funder_only should default to false
        @org.update(managed: true, funder: true)
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to be(true)
      end

      it 'obeys the :managed_only flag' do
        @org.update(managed: false)
        results = @controller.send(:orgs_search, term: @org.name, managed_only: true)
        expect(results.include?(@org)).to be(false)
      end

      it 'obeys the :funder_only flag' do
        @org.update(funder: false)
        results = @controller.send(:orgs_search, term: @org.name, funder_only: true)
        expect(results.include?(@org)).to be(false)
      end

      it 'obeys the :non_funder_only flag' do
        @org.update(funder: true)
        results = @controller.send(:orgs_search, term: @org.name, non_funder_only: true)
        expect(results.include?(@org)).to be(false)
      end

      it 'returns the expected results' do
        results = @controller.send(:orgs_search, term: @org.name)
        expect(results.include?(@org)).to be(true)
      end
    end

    describe ':registry_orgs_search(term:, **options)' do
      before do
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
        expect(results.include?(@registry_org)).to be(true)

        # :known_only should default to false
        @registry_org.update(org_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to be(true)

        # :funder_only should default to false
        @registry_org.update(fundref_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to be(true)

        # :non_funder_only should default to false
        @registry_org.update(fundref_id: Faker::Internet.url)
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to be(true)
      end

      it 'obeys the :known_only flag' do
        @registry_org.update(org_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name, known_only: true)
        expect(results.include?(@registry_org)).to be(false)
      end

      it 'obeys the :funder_only flag' do
        @registry_org.update(fundref_id: nil)
        results = @controller.send(:registry_orgs_search, term: @org.name, funder_only: true)
        expect(results.include?(@registry_org)).to be(false)
      end

      it 'obeys the :non_funder_only flag' do
        @registry_org.update(fundref_id: Faker::Internet.url)
        results = @controller.send(:registry_orgs_search, term: @org.name, non_funder_only: true)
        expect(results.include?(@registry_org)).to be(false)
      end

      it 'obeys the :managed_only flag' do
        @org.update(managed: false)
        results = @controller.send(:registry_orgs_search, term: @org.name, managed_only: true)
        expect(results.include?(@registry_org)).to be(false)
      end

      it 'returns the expected results' do
        results = @controller.send(:registry_orgs_search, term: @org.name)
        expect(results.include?(@registry_org)).to be(true)
      end
    end

    describe ':weigh(term:, org:)' do
      before do
        @term = Faker::Music::PearlJam.song.tr(' ', '-').upcase
        # Make sure the names do not include the search term so we can control scenarios
        @org.name = Faker::Lorem.sentence.gsub(@term, '')
        @registry_org.name = Faker::Lorem.sentence.gsub(@term, '')
      end

      it 'returns 0 if :term is not present?' do
        expect(@controller.send(:weigh, term: nil, org: @org)).to be(0)
      end

      it 'returns 0 if :org is not an Org or RegistryOrg' do
        expect(@controller.send(:weigh, term: @term, org: 'Foo')).to be(0)
      end

      it 'returns 1 if all we could match is on the RegistryOrg acronym' do
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to be(1)
      end

      it 'returns 1 if all we could match is on the Org abbreviation' do
        @org.abbreviation = @term
        expect(@controller.send(:weigh, term: @term, org: @org)).to be(1)
      end

      it 'returns 2 if all we could determine is that the name starts with the term' do
        @org.name = "#{@term} - #{@org.name}"
        expect(@controller.send(:weigh, term: @term, org: @org)).to be(2)
      end

      it 'returns 1 if all we could determine was that the RegistryOrg has an :org_id' do
        @registry_org.org_id = @org.id
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to be(1)
      end

      it 'returns 1 if all we could determine was that the name includes the term (not start_with)' do
        @org.name = "#{@org.name} (#{@term})"
        expect(@controller.send(:weigh, term: @term, org: @org)).to be(1)
      end

      it 'returns 3 if name starts with the :term, the RegistryOrg has an :org_id' do
        @registry_org.org_id = @org.id
        @registry_org.name = "#{@term} - #{@org.name}"
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to be(3)
      end

      it 'returns 3 if name starts with the :term, the Org :abbreviation matches' do
        @org.abbreviation = @term
        @registry_org.name = "#{@term} - #{@org.name}"
        expect(@controller.send(:weigh, term: @term, org: @org)).to be(1)
      end

      it 'returns 4 if name starts with the :term, the :acronym matches, the RegistryOrg has an :org_id' do
        @registry_org.org_id = @org.id
        @registry_org.name = "#{@term} - #{@org.name}"
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to be(4)
      end

      it 'returns 2 if the RegistryOrg :acronym matches and the :org_id is present' do
        @registry_org.org_id = @org.id
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to be(2)
      end

      it 'returns 2 if the :acronym matches and the :name includes the :term' do
        @registry_org.name = "#{@org.name} (#{@term})"
        @registry_org.acronyms = (@registry_org.acronyms << @term)
        expect(@controller.send(:weigh, term: @term, org: @registry_org)).to be(2)
      end

      it 'returns 2 if the :abbreviation matches and the :name includes the :term' do
        @org.name = "#{@org.name} (#{@term})"
        @org.abbreviation = @term
        expect(@controller.send(:weigh, term: @term, org: @org)).to be(2)
      end
    end

    describe 'deduplicate(term:, list: [])' do
      before do
        @other_registry_org = create(:registry_org, name: "Another one like #{@org.name}")
        @predominant_org = create(:org, name: "predominent #{@org.name.downcase}")
        @duplicate_registry_org = create(:registry_org, name: "another one like #{@org.name}".downcase)
        @duplicate_org = create(:org, name: "#{@org.name.downcase}foo")

        create(:user, org: @predominant_org)
        create(:user, org: @predominant_org)
        create(:user, org: @predominant_org)
      end

      it 'returns an empty array if results is not present' do
        expect(@controller.send(:deduplicate, list: nil, term: @org.name))
      end

      it 'returns an empty array if results is empty' do
        expect(@controller.send(:deduplicate, list: [], term: @org.name))
      end

      it 'returns an empty array if term is not present' do
        expect(@controller.send(:deduplicate, list: [@org], term: nil))
      end

      it 'calls :weigh for each result' do
        @controller.expects(:weigh).twice
        @controller.send(:deduplicate, list: [@org, @registry_org], term: @org.name)
      end

      it 'sorts the results by user_count desc, weight desc and name asc' do
        @controller.expects(:weigh).with(term: @org.name, org: @registry_org).returns(3)
        @controller.expects(:weigh).with(term: @org.name, org: @other_registry_org).returns(1)
        @controller.expects(:weigh).with(term: @org.name, org: @predominant_org).returns(3)
        results = @controller.send(:deduplicate, list: [@predominant_org, @other_registry_org,
                                                        @registry_org],
                                                 term: @org.name)
        expect(results.length).to be(3)
        expect(results.first).to eql(@predominant_org)
        expect(results.last).to eql(@other_registry_org)
      end

      it 'does not return the duplicate records' do
        results = @controller.send(:deduplicate, list: [@registry_org, @other_registry_org,
                                                        @duplicate_registry_org, @org,
                                                        @predominant_org, @duplicate_org],
                                                 term: @org.name)

        expect(results.include?(@registry_org)).to be(true)
        expect(results.include?(@other_registry_org)).to be(true)
        expect(results.include?(@org)).to be(true)
        expect(results.include?(@predominant_org)).to be(true)

        expect(results.include?(@duplicate_registry_org)).to be(false)
      end
    end
  end
end
