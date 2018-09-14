require 'spec_helper'

RSpec.describe LocaleSet do

  describe "#for" do

    subject { LocaleSet.new(['en_gb', 'EN-US', :es, :fr]).for(format) }

    let!(:format) { :i18n }

    it "converts each item to a string" do
      subject.each do |item|
        expect(item).to be_a(String)
      end
    end

    it "removes duplicate items" do
      @locale_set = LocaleSet.new([:es, :es])
      expect(@locale_set).to have(1).item
    end

    context "when format is :i18n" do

      let!(:format) { :i18n }

      it "returns each item in i18n format" do
        expect(subject).to eql(['en-GB', 'en-US', 'es', 'fr'])
      end

    end

    context "when format is :fast_gettext" do

      let!(:format) { :fast_gettext }

      it "returns each item in fast_gettext format" do
        expect(subject).to eql(['en_GB', 'en_US', 'es', 'fr'])
      end

    end

  end

end
