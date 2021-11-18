# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::OrgPresenter do

  describe "#affiliation_id" do
    before(:each) do
      @ror_scheme = create(:identifier_scheme, name: "ror")
      @fundref_scheme = create(:identifier_scheme, name: "fundref")
      @org = create(:org)
      create(:identifier, identifiable: @org)
      @org.reload
    end

    it "returns nil if no ORCID exists" do
      rslt = described_class.affiliation_id(identifiers: @org.identifiers)
      expect(rslt).to eql(nil)
    end
    it "returns the ROR" do
      ror = create(:identifier, identifier_scheme: @ror_scheme, identifiable: @org)
      create(:identifier, identifier_scheme: @fundref_scheme, identifiable: @org)
      @org.reload
      rslt = described_class.affiliation_id(identifiers: @org.identifiers)
      expect(rslt).to eql(ror)
    end
    it "returns the FUNDREF if no ROR is present" do
      fundref = create(:identifier, identifier_scheme: @fundref_scheme,
                                    identifiable: @org)
      @org.reload
      rslt = described_class.affiliation_id(identifiers: @org.identifiers)
      expect(rslt).to eql(fundref)
    end
  end

end
