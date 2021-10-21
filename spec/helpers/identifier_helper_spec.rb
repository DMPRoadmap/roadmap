# frozen_string_literal: true

require "rails_helper"

describe IdentifierHelper do
  include IdentifierHelper

  before(:each) do
    @user_scheme = create(:identifier_scheme, for_users: true)
  end

  describe "#id_for_display(id:, with_scheme_name)" do
    before(:each) do
      @none = _("None defined")
      url = Faker::Internet.url
      @user_scheme.identifier_prefix = url
      val = "#{url}/#{Faker::Lorem.word}"
      @identifier = create(:identifier, identifier_scheme: @user_scheme,
                                        value: val)
    end

    it "defaults to showing the scheme name" do
      rslt = id_for_display(id: @identifier)
      expect(rslt.include?(@user_scheme.identifier_prefix)).to eql(true)
    end
    it "does not display the scheme name if flag is set" do
      rslt = id_for_display(id: @identifier, with_scheme_name: false)
      expect(rslt.include?(@user_scheme.name)).to eql(false)
    end
    it "returns the correct text when the identifier is new" do
      id = build(:identifier)
      rslt = id_for_display(id: id)
      expect(rslt).to eql(@none)
    end
    it "returns the correct text when the identifier is blank" do
      @identifier.value = ""
      rslt = id_for_display(id: @identifier)
      expect(rslt).to eql(@none)
    end
    it "returns the value when the scheme has no identifier_prefix" do
      val = Faker::Lorem.word
      @user_scheme.identifier_prefix = nil
      @user_scheme.save
      @identifier.value = val
      rslt = id_for_display(id: @identifier)
      expect(rslt).to eql(@user_scheme.description + ": " + val)
    end
    it "returns the value as a link when the scheme has a identifier_prefix" do
      rslt = id_for_display(id: @identifier)
      expect(rslt.include?(@identifier.value)).to eql(true)
    end
  end

end
