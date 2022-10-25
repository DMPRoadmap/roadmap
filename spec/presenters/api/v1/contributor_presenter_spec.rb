# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::ContributorPresenter do
  describe '#role_as_uri' do
    it 'returns nil if the plans_contributor role is nil' do
      uri = described_class.role_as_uri(role: nil)
      expect(uri).to be_nil
    end

    it 'returns the correct URI' do
      uri = described_class.role_as_uri(role: 'data_curation')
      expect(uri.start_with?('http')).to be(true)
      expect(uri.end_with?('data-curation')).to be(true)
    end
  end

  describe '#contributor_id' do
    before do
      @contributor = create(:contributor, investigation: true, plan: create(:plan))
      create(:identifier, identifiable: @contributor)
      @contributor.reload
    end

    it 'returns nil if no ORCID exists' do
      rslt = described_class.contributor_id(identifiers: @contributor.identifiers)
      expect(rslt).to be_nil
    end

    it 'returns the ORCID' do
      scheme = create(:identifier_scheme, name: 'orcid')
      orcid = create(:identifier, identifier_scheme: scheme, identifiable: @contributor)
      @contributor.reload
      rslt = described_class.contributor_id(identifiers: @contributor.identifiers)
      expect(rslt).to eql(orcid)
    end
  end
end
