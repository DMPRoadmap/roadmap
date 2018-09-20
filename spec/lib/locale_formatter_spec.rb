require 'spec_helper'

RSpec.describe LocaleFormatter do

  context "#format" do

    subject { LocaleFormatter.new('en_GB').format }

    it "defaults to :i18n" do
      expect(subject).to eql(:i18n)
    end

  end

  describe "#string" do

    context "when format is :i18n" do

      subject { LocaleFormatter.new(locale_string, format: format).string }

      let(:locale_string) { 'HH_xx' }

      let!(:format) { :i18n }

      it "forces the hyphenated format" do
        expect(subject).to eql("hh-XX")
      end

      it "downcases the language component" do
        expect(subject).to start_with('hh')
      end

      it "upcases the region" do
        expect(subject).to end_with('XX')
      end

    end

    context "when format is :fast_gettext" do

      subject { LocaleFormatter.new(locale_string, format: format).string }

      let(:locale_string) { 'HH-xx' }

      let!(:format) { :fast_gettext }

      it "forces the underescore format" do
        expect(subject).to eql("hh_XX")
      end

      it "downcases the language component" do
        expect(subject).to start_with('hh')
      end

      it "upcases the region" do
        expect(subject).to end_with('XX')
      end

    end

  end

end
