# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocaleService do
  before(:each) do
    Language.destroy_all
    @default = Language.default || create(:language, abbreviation: 'loc-svc', default_language: true)
    Rails.configuration.x.locales.default = @default.abbreviation
    Rails.configuration.x.locales.gettext_join_character = '_'
    Rails.configuration.x.locales.i18n_join_character = '-'
  end

  describe '#default_locale' do
    it 'returns the Language defined as the default in the database' do
      Language.update_all(default_language: false)
      create(:language, abbreviation: 'zz-TP', default_language: true)
      expect(described_class.default_locale).to eql('zz-TP')
    end
    it 'returns the default language defined in dmproadmap.rb initializer' do
      Language.destroy_all
      expect(described_class.default_locale).to eql(@default.abbreviation)
    end
  end

  describe '#available_locales' do
    it 'returns the abbreviations of all Languages in the database' do
      create(:language, abbreviation: 'avail-loc')
      expected = Language.all.order(:abbreviation).pluck(:abbreviation)
      expect(described_class.available_locales).to eql(expected)
    end
    it 'returns the default language if no Languages are in the database' do
      Language.destroy_all
      expect(described_class.available_locales).to eql([@default.abbreviation])
    end
  end

  describe '#to_i18n(locale:)' do
    it 'uses the default_locale if no locale is specified' do
      expect(described_class.to_i18n(locale: nil)).to eql(@default.abbreviation)
    end
    it 'converts the locale to i18n format' do
      expect(described_class.to_i18n(locale: 'en-GB')).to eql('en-GB')
      expect(described_class.to_i18n(locale: 'en_GB')).to eql('en-GB')
      expect(described_class.to_i18n(locale: 'en|GB')).to eql('en-GB')
    end
  end

  describe '#to_gettext(locale:)' do
    it 'uses the default_locale if no locale is specified' do
      expect(described_class.to_gettext(locale: nil)).to eql(LocaleService.to_gettext(locale: @default.abbreviation))
    end
    it 'converts the locale to Gettext format' do
      expect(described_class.to_gettext(locale: 'en_GB')).to eql('en_GB')
      expect(described_class.to_gettext(locale: 'en-GB')).to eql('en_GB')
      expect(described_class.to_gettext(locale: 'en|GB')).to eql('en_GB')
    end
  end

  context 'private methods' do
    describe '#convert(string:, join_char:)' do
      it 'handles a 2 character locale (e.g. `en`)' do
        expect(described_class.send(:convert, string: 'en')).to eql('en')
      end
      it 'handles a locale with an extension (e.g. `en-GB`)' do
        expect(described_class.send(:convert, string: 'en|GB')).to eql('en_GB')
      end
      it 'handles a locale as upper case (e.g. `EN-GB`)' do
        expect(described_class.send(:convert, string: 'EN|GB')).to eql('en_GB')
      end
      it 'handles a locale as lower case (e.g. `en-gb`)' do
        expect(described_class.send(:convert, string: 'en|gb')).to eql('en_GB')
      end
      it 'uses the specified join_char' do
        result = described_class.send(:convert, string: 'en|gb', join_char: '+')
        expect(result).to eql('en+GB')
      end
      it 'defaults to Gettext join_char' do
        expect(described_class.send(:convert, string: 'en-GB')).to eql('en_GB')
      end
    end
  end
end
