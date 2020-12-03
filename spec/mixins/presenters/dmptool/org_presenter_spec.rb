# frozen_string_literal: true

require "rails_helper"

RSpec.describe Dmptool::OrgPresenter do

  describe "DMPTool OrgPresenter" do
    before do
      @managed = create(:org, managed: true)
      @unmanaged = create(:org, managed: false)
      @scheme = create(:identifier_scheme, name: "shibboleth")
      @presenter = described_class.new
    end

    describe "#initialize" do
      it "initializes if a shibboleth scheme is available" do
        expect(@presenter.is_a?(Dmptool::OrgPresenter)).to eql(true)
      end
      it "initializes if a shibboleth scheme is NOT available" do
        @scheme.destroy
        presenter = described_class.new
        expect(presenter.is_a?(Dmptool::OrgPresenter)).to eql(true)
      end
    end

    describe "#participating_orgs" do
      it "returns 'managed' Orgs" do
        expect(@presenter.participating_orgs.include?(@managed)).to eql(true)
      end
      it "does not return 'unmanaged' Orgs" do
        expect(@presenter.participating_orgs.include?(@unmanaged)).to eql(false)
      end
    end

    describe "#sign_in_url(org:)" do
      it "returns nil if the :org is not present" do
        expect(@presenter.sign_in_url(org: nil)).to eql(nil)
      end
      it "returns nil if there is no shibboleth scheme" do
        @scheme.destroy
        @presenter = described_class.new
        expect(@presenter.sign_in_url(org: @managed)).to eql(nil)
      end
      it "returns the correct URL/path" do
        result = @presenter.sign_in_url(org: @unmanaged)
        path = Rails.application.routes.url_helpers.shibboleth_ds_path
        expect(result.starts_with?(path)).to eql(true)
        expect(result.ends_with?(@unmanaged.id.to_s)).to eql(true)
      end
    end
  end

end
