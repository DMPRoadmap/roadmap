require 'rails_helper'


RSpec.describe Org, type: :model do

  describe "DMPTool customizations to Org model" do

    before do
      generate_shibbolized_orgs(10)
    end

    context ".participating" do

      it "is_other org is not included in list of participating" do
        org = create(:org, is_other: true)
        expect(Org.participating.include?(org)).to eql(false)
      end

      it ".participating includes correct orgs" do
        expect(Org.participating.size).to eql(10)
      end

    end

    context ".shibbolized?" do

      it "when Org does not have an identifier for Shibboleth" do
        org = create(:org, is_other: false)
        expect(org.shibbolized?).to eql(false)
      end

      it "when the Org has a shibboleth identifier" do
        org = Org.participating.first
        expect(org.shibbolized?).to eql(true)
      end
    end

  end

end