# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dmptool::Models::Org, type: :model do

  describe "DMPTool customizations to Org model" do

    before do
      generate_shibbolized_orgs(2)
      @unmanaged = create(:org, managed: false)
    end

    it "Org includes our cusotmizations" do
      expect(::Org.respond_to?(:participating)).to eql(true)
    end

    context "#participating" do
      it "does not return unmanaged orgs" do
        expect(Org.participating.include?(@unmanaged)).to eql(false)
      end
      it "includes managed orgs" do
        expect(Org.participating.size).to eql(3)
      end
    end

    context "#shibbolized?" do
      it "returns false when the Org is not :managed" do
        org = Org.participating.first
        org.update(managed: false)
        expect(org.shibbolized?).to eql(false)
      end
      it "returns false if Org does not have an identifier for Shibboleth" do
        expect(@unmanaged.shibbolized?).to eql(false)
      end
      it "returns true" do
        org = Org.participating.first
        expect(org.shibbolized?).to eql(true)
      end
    end

  end

end
