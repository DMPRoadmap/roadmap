# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::ContextualErrorService do
  before(:each) do
    @plan = build(:plan)
    @plan.identifiers << build(:identifier)
    @plan.contributors << build(:contributor, org: build(:org), investigation: true)
    @plan.contributors.first.identifiers << build(:identifier)
    @plan.funder = build(:org)
    @plan.grant = { value: build(:identifier).value }
  end

  describe ':contextualize_errors(plan:)' do
    it 'returns an empty array if :plan is not present' do
      expect(described_class.contextualize_errors(plan: nil)).to eql([])
    end
    it 'returns errors if an associated Dataset has errors' do
      @plan.research_outputs << build(:research_output, title: nil)
      expected = ['Dataset : ["Title can\'t be blank"]']
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
    it 'returns errors if an associated Contributor has errors' do
      contrib = build(:contributor)
      @plan.contributors << contrib
      # rubocop:disable Layout/LineLength
      expected = ["Contributor/Contact: '#{contrib.name}' : [\"Roles can't be blank\", \"Roles You must specify at least one role.\"]"]
      # rubocop:enable Layout/LineLength
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
    it 'returns errors if an associated Contributor Affiliation has errors' do
      contrib = build(:contributor, investigation: true, org: build(:org, name: nil))
      @plan.contributors << contrib
      expected = ["Contributor/Contact: '#{contrib.name}' : [\"Affiliation: '' : [\\\"Name can't be blank\\\"]\"]"]
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
    it 'returns errors if an associated RelatedIdentifier has errors' do
      @plan.related_identifiers << build(:related_identifier, value: nil)
      expected = ['Related Identifier : ["Value can\'t be blank"]']
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
    it 'returns errors if an associated Funder has errors' do
      @plan.funder = build(:org, name: nil)
      expected = ['Project : ["Funder: \'\' : [\\"Name can\'t be blank\\"]"]']
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
    it 'returns errors if an associated Identifier has errors' do
      @plan.identifiers.first.value = nil
      expected = ['identifier: \'\' - ["Value can\'t be blank"]']
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
    it 'returns errors for the Plan' do
      @plan.title = nil
      expected = ['Plan: ["Title can\'t be blank"]']
      expect(described_class.contextualize_errors(plan: @plan)).to eql(expected)
    end
  end

  context 'private methods' do
    describe ':find_project_errors(plan:)' do
      it 'returns an empty array if :plan is not present' do
        expect(described_class.send(:find_project_errors, plan: nil)).to eql([])
      end
      it 'returns an empty array if :plan is valid according to ActiveRecord' do
        expect(described_class.send(:find_project_errors, plan: @plan)).to eql([])
      end
      it 'appends any errors associated with the funding :org' do
        described_class.expects(:find_org_errors).once.returns(['foo'])
        expect(described_class.send(:find_project_errors, plan: @plan)).to eql(['Project : ["foo"]'])
      end
    end

    describe 'find_dataset_errors(dataset:)' do
      before(:each) do
        @dataset = build(:research_output, plan: @plan)
      end

      it 'returns an empty array if :dataset is not present' do
        expect(described_class.send(:find_dataset_errors, dataset: nil)).to eql([])
      end
      it 'returns an empty array if :dataset is valid according to ActiveRecord' do
        expect(described_class.send(:find_dataset_errors, dataset: @dataset)).to eql([])
      end
      it 'contextualizes the errors' do
        @dataset.title = nil
        expected = ['Dataset : ["Title can\'t be blank"]']
        expect(described_class.send(:find_dataset_errors, dataset: @dataset)).to eql(expected)
      end
    end

    describe 'find_org_errors(org:)' do
      before(:each) do
        @org = build(:org)
      end

      it 'returns an empty array if :org is not present' do
        expect(described_class.send(:find_org_errors, org: nil)).to eql([])
      end
      it 'returns an empty array if :org is valid according to ActiveRecord' do
        expect(described_class.send(:find_org_errors, org: @org)).to eql([])
      end
      it 'includes the errors of any associated identifiers' do
        @org.identifiers << build(:identifier, value: nil)
        expected = ["Affiliation: '#{@org.name}' : [\"Identifiers value can't be blank\"]"]
        expect(described_class.send(:find_org_errors, org: @org)).to eql(expected)
      end
      it 'contextualizes the errors' do
        @org.name = nil
        expected = ['Affiliation: \'\' : ["Name can\'t be blank"]']
        expect(described_class.send(:find_org_errors, org: @org)).to eql(expected)
      end
    end

    describe 'find_contributor_errors(contributor:)' do
      before(:each) do
        @contributor = build(:contributor, investigation: true)
      end

      it 'returns an empty array if :contributor is not present' do
        expect(described_class.send(:find_contributor_errors, contributor: nil)).to eql([])
      end
      it 'returns an empty array if :contributor is valid according to ActiveRecord' do
        expect(described_class.send(:find_contributor_errors, contributor: @contributor)).to eql([])
      end
      it 'includes the errors of any associated identifiers' do
        @contributor.identifiers << build(:identifier, value: nil)
        expected = ["Contributor/Contact: '#{@contributor.name}' : [\"Identifiers value can't be blank\"]"]
        expect(described_class.send(:find_contributor_errors, contributor: @contributor)).to eql(expected)
      end
      it 'contextualizes the errors' do
        @contributor.name = nil
        @contributor.email = nil
        # rubocop:disable Layout/LineLength
        expected = ['Contributor/Contact: \'\' : ["Name can\'t be blank if no email is provided.", "Email can\'t be blank if no name is provided"]']
        # rubocop:enable Layout/LineLength
        expect(described_class.send(:find_contributor_errors, contributor: @contributor)).to eql(expected)
      end
    end

    describe 'find_related_identifier_errors(related_identifier:)' do
      before(:each) do
        @id = build(:related_identifier)
      end

      it 'returns an empty array if :related_identifier is not present' do
        expect(described_class.send(:find_related_identifier_errors, related_identifier: nil)).to eql([])
      end
      it 'returns an empty array if :related_identifier is valid according to ActiveRecord' do
        expect(described_class.send(:find_related_identifier_errors, related_identifier: @id)).to eql([])
      end
      it 'contextualizes the errors' do
        @id.value = nil
        expected = ['Related Identifier : ["Value can\'t be blank"]']
        expect(described_class.send(:find_related_identifier_errors, related_identifier: @id)).to eql(expected)
      end
    end
  end
end
