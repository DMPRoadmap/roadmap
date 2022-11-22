# frozen_string_literal: true

require 'rails_helper'

describe IdentifierHelper do
  include described_class

  before do
    @user_scheme = create(:identifier_scheme, for_users: true)
    ::DmpIdService.stubs(:identifier_scheme).returns(@user_scheme)
  end

  describe '#id_for_display(id:, with_scheme_name)' do
    before do
      @none = _('None defined')
      url = Faker::Internet.url
      @user_scheme.identifier_prefix = url
      val = "#{url}/#{Faker::Lorem.word}"
      @identifier = create(:identifier, identifier_scheme: @user_scheme,
                                        value: val)
    end

    it 'defaults to showing the scheme name (when in PROD)' do
      Rails.env = 'production'
      rslt = id_for_display(id: @identifier)
      expect(rslt.include?(@user_scheme.identifier_prefix)).to be(true)
    end

    it 'does not display the scheme name if flag is set' do
      rslt = id_for_display(id: @identifier, with_scheme_name: false)
      expect(rslt.include?(@user_scheme.name)).to be(false)
    end

    it 'returns the correct text when the identifier is new' do
      id = build(:identifier)
      rslt = id_for_display(id: id)
      expect(rslt).to eql(@none)
    end

    it 'returns the correct text when the identifier is blank' do
      @identifier.value = ''
      rslt = id_for_display(id: @identifier)
      expect(rslt).to eql(@none)
    end

    it 'returns the value when the scheme has no identifier_prefix' do
      Rails.env = 'production'
      val = Faker::Lorem.word
      @user_scheme.identifier_prefix = nil
      @user_scheme.save
      @identifier.value = val
      rslt = id_for_display(id: @identifier)
      expect(rslt).to eql("#{@user_scheme.description}: #{val}")
    end

    it 'returns the value as a link when the scheme has a identifier_prefix' do
      Rails.env = 'production'
      rslt = id_for_display(id: @identifier)
      expect(rslt.include?(@identifier.value)).to be(true)
    end

    it "returns the value with the DmpIdService's identifier prefix (when not in PROD)" do
      Rails.env = 'development'
      rslt = id_for_display(id: @identifier)
      expect(rslt.include?(::DmpIdService.landing_page_url)).to be(true)
    end

    it "returns the value with the DmpIdService's identifier prefix (when not in PROD) and flag set" do
      Rails.env = 'stage'
      rslt = id_for_display(id: @identifier, with_scheme_name: false)
      expect(rslt.include?(::DmpIdService.landing_page_url)).to be(true)
    end
  end
end
