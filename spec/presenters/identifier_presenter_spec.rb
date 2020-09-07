# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdentifierPresenter do

  before(:each) do
    @user = create(:user)
    @user_scheme = create(:identifier_scheme, for_users: true)
    @plan_scheme = create(:identifier_scheme, for_plans: true, for_users: false)
    @org_scheme = create(:identifier_scheme, for_orgs: true, for_users: false)
  end

  describe "#identifiers" do
    it "returns the identiable object's identifiers" do
      id = build(:identifier)
      @user.identifiers << id
      @user.org.identifiers << build(:identifier)
      presenter = described_class.new(identifiable: @user)
      expect(presenter.identifiers.length).to eql(1)
      expect(presenter.identifiers.first).to eql(id)
    end
  end

  describe "#id_for_scheme(scheme:)" do
    before(:each) do
      @user_id = build(:identifier, identifier_scheme: @user_scheme)
      @user_id2 = build(:identifier, identifier_scheme: @org_scheme)
      @user.identifiers = [@user_id, @user_id2]
      @presenter = described_class.new(identifiable: @user)
    end

    it "initializes a new identifier if no matching identifiers exist" do
      rslt = @presenter.id_for_scheme(scheme: @plan_scheme)
      expect(rslt.new_record?).to eql(true)
    end

    it "returns the correct identifier" do
      rslt = @presenter.id_for_scheme(scheme: @user_scheme)
      expect(rslt).to eql(@user_id)
    end
  end

  describe "#scheme_by_name(name:)" do
    it "returns the correct scheme" do
      presenter = described_class.new(identifiable: @user)
      rslt = presenter.scheme_by_name(name: @user_scheme.name)
      expect(rslt.first).to eql(@user_scheme)
    end
  end

  describe "#id_for_display(id:, with_scheme_name)" do
    before(:each) do
      @none = _("None defined")
      @presenter = described_class.new(identifiable: @user)

      url = Faker::Internet.url
      @user_scheme.identifier_prefix = url
      val = "#{url}/#{Faker::Lorem.word}"
      @identifier = create(:identifier, identifier_scheme: @user_scheme,
                                        value: val)
    end

    it "defaults to showing the scheme name" do
      rslt = @presenter.id_for_display(id: @identifier)
      expect(rslt.include?(@user_scheme.identifier_prefix)).to eql(true)
    end
    it "does not display the scheme name if flag is set" do
      rslt = @presenter.id_for_display(id: @identifier, with_scheme_name: false)
      expect(rslt.include?(@user_scheme.name)).to eql(false)
    end
    it "returns the correct text when the identifier is new" do
      id = build(:identifier)
      rslt = @presenter.id_for_display(id: id)
      expect(rslt).to eql(@none)
    end
    it "returns the correct text when the identifier is blank" do
      @identifier.value = ""
      rslt = @presenter.id_for_display(id: @identifier)
      expect(rslt).to eql(@none)
    end
    it "returns the value when the scheme has no identifier_prefix" do
      val = Faker::Lorem.word
      @user_scheme.identifier_prefix = nil
      @user_scheme.save
      @identifier.value = val
      rslt = @presenter.id_for_display(id: @identifier)
      expect(rslt).to eql(@user_scheme.description + ": " + val)
    end
    it "returns the value as a link when the scheme has a identifier_prefix" do
      rslt = @presenter.id_for_display(id: @identifier)
      expect(rslt.include?(@identifier.value)).to eql(true)
    end
  end

  context "#schemes" do
    describe "when the identifiable object is an Org" do
      before(:each) do
        @presenter = described_class.new(identifiable: build(:org))
      end

      it "returns schemes appropriate to the Org context" do
        expect(@presenter.schemes.include?(@org_scheme)).to eql(true)
      end
      it "does not return schemes for other contexts" do
        expect(@presenter.schemes.include?(@user_scheme)).not_to eql(true)
        expect(@presenter.schemes.include?(@plan_scheme)).not_to eql(true)
      end
    end

    describe "when the identifiable object is an Plan" do
      before(:each) do
        @presenter = described_class.new(identifiable: build(:plan))
      end

      it "returns schemes appropriate to the Plan context" do
        expect(@presenter.schemes.include?(@plan_scheme)).to eql(true)
      end
      it "does not return schemes for other contexts" do
        expect(@presenter.schemes.include?(@user_scheme)).not_to eql(true)
        expect(@presenter.schemes.include?(@org_scheme)).not_to eql(true)
      end
    end

    describe "when the identifiable object is an User" do
      before(:each) do
        @presenter = described_class.new(identifiable: build(:user))
      end

      it "returns schemes appropriate to the User context" do
        expect(@presenter.schemes.include?(@user_scheme)).to eql(true)
      end
      it "does not return schemes for other contexts" do
        expect(@presenter.schemes.include?(@org_scheme)).not_to eql(true)
        expect(@presenter.schemes.include?(@plan_scheme)).not_to eql(true)
      end
    end
  end

end
