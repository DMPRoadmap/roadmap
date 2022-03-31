# frozen_string_literal: true

require 'rails_helper'

describe License do
  context 'associations' do
    it { is_expected.to have_many :research_outputs }
  end

  context 'scopes' do
    describe '#selectable' do
      before(:each) do
        @license = create(:license, deprecated: false)
        @deprecated = create(:license, deprecated: true)
      end

      it 'does not include deprecated licenses' do
        expect(described_class.selectable.include?(@deprecated)).to eql(false)
      end
      it 'includes non-depracated licenses' do
        expect(described_class.selectable.include?(@license)).to eql(true)
      end
    end

    describe '#preferred' do
      before(:each) do
        @preferred_license = create(:license, deprecated: false)
        @non_preferred_license = create(:license, deprecated: false)

        @preferred_oldest = create(:license, deprecated: false)
        @preferred_older = create(:license, identifier: "#{@preferred_oldest.identifier}-1.0",
                                            deprecated: false)
        @preferred_latest = create(:license, identifier: "#{@preferred_oldest.identifier}-1.1",
                                             deprecated: false)

        Rails.configuration.x.madmp.preferred_licenses = [
          @preferred_license.identifier,
          "#{@preferred_oldest.identifier}-%{latest}"
        ]
      end

      it 'calls :selectable if no preferences are defined in the app config' do
        Rails.configuration.x.madmp.preferred_licenses = nil
        described_class.expects(:selectable).returns([@license])
        described_class.preferred
      end
      it 'does not include non-preferred licenses' do
        expect(described_class.preferred.include?(@non_preferred_license)).to eql(false)
      end
      it 'includes preferred licenses' do
        expect(described_class.preferred.include?(@preferred_license)).to eql(true)
      end
      it 'includes the latest version of a preferred licenses' do
        expect(described_class.preferred.include?(@preferred_latest)).to eql(true)
        expect(described_class.preferred.include?(@preferred_oldest)).to eql(false)
        expect(described_class.preferred.include?(@preferred_older)).to eql(false)
      end
    end
  end
end
