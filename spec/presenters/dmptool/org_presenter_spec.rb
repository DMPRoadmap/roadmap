# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dmptool::OrgPresenter do
  describe 'DMPTool OrgPresenter' do
    before do
      @managed = create(:org, managed: true)
      @unmanaged = create(:org, managed: false)
      @scheme = create(:identifier_scheme, name: 'shibboleth')
      @presenter = described_class.new
    end

    describe '#initialize' do
      it 'initializes if a shibboleth scheme is available' do
        expect(@presenter.is_a?(Dmptool::OrgPresenter)).to eql(true)
      end
      it 'initializes if a shibboleth scheme is NOT available' do
        @scheme.destroy
        presenter = described_class.new
        expect(presenter.is_a?(Dmptool::OrgPresenter)).to eql(true)
      end
    end

    describe '#participating_orgs' do
      it "returns 'managed' Orgs" do
        expect(@presenter.participating_orgs.include?(@managed)).to eql(true)
      end
      it "does not return 'unmanaged' Orgs" do
        expect(@presenter.participating_orgs.include?(@unmanaged)).to eql(false)
      end
    end
  end
end
