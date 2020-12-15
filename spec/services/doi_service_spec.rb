# frozen_string_literal: true

require "rails_helper"

RSpec.describe DoiService do
  include ConfigHelper

  before(:each) do
    @config = OpenStruct.new(active: true,
                             name: Faker::Lorem.unique.word,
                             landing_page_url: Faker::Internet.url,
                             description: Faker::Lorem.sentence)

    @scheme = create(:identifier_scheme, name: @config.name,
                                         identifier_prefix: @config.landing_page_url,
                                         description: @config.description,
                                         for_identification: true, for_plans: true)
  end

  describe "#mint_doi(plan:)" do
    before(:each) do
      @plan = build(:plan)
      @doi = SecureRandom.uuid
      @qualified_doi = "#{@config.landing_page_url}#{@doi}"
    end

    it "returns nil if :plan is not present" do
      expect(described_class.mint_doi(plan: nil)).to eql(nil)
    end
    it "returns nil if :plan is not an instance of Plan" do
      expect(described_class.mint_doi(plan: build(:org))).to eql(nil)
    end
    it "returns the existing DOI if :plan already has a :doi" do
      existing = build(:identifier, identifier_scheme: @scheme, value: @qualified_doi)
      @plan.stubs(:doi).returns(existing)
      expect(described_class.mint_doi(plan: @plan).value).to eql(@qualified_doi)
    end
    it "returns nil if if no DOI minting service is active" do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.mint_doi(plan: @plan)).to eql(nil)
    end
    it "returns nil if the DOI minting service did not receive a DOI" do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      ExternalApis::DataciteService.stubs(:mint_doi).returns(nil)
      expect(described_class.mint_doi(plan: @plan)).to eql(nil)
    end
    it "returns the DOI retrieved by the DOI minting service" do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      ExternalApis::DataciteService.stubs(:mint_doi).returns(@qualified_doi)
      expect(described_class.mint_doi(plan: @plan).value).to eql(@qualified_doi)
    end
    it "prepends the :landing_page_url if the DOI is not a URL" do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      ExternalApis::DataciteService.stubs(:landing_page_url)
                                   .returns(@config.landing_page_url)
      ExternalApis::DataciteService.stubs(:mint_doi).returns(@doi)
      expect(described_class.mint_doi(plan: @plan).value).to eql(@qualified_doi)
    end
    it "does not prepend the :landing_page_url if the DOI is already a URL" do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      ExternalApis::DataciteService.stubs(:mint_doi).returns(@qualified_doi)
      expected = "#{@scheme.identifier_prefix}#{@qualified_doi}"
      expect(described_class.mint_doi(plan: @plan).value).not_to eql(expected)
    end
  end

  describe "#minting_service_defined?" do
    it "returns false if no DOI minting service is active" do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.minting_service_defined?).to eql(false)
    end
    it "returns true if a DOI minting service is active" do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      expect(described_class.minting_service_defined?).to eql(true)
    end
  end

  describe "#scheme_name" do
    it "returns nil if there is no active Doi minting service" do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.scheme_name).to eql(nil)
    end
    it "returns the name of IdentifierScheme associated with the DOI minting service" do
      @config.name = @config.name.upcase
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@config)
      expect(described_class.scheme_name).to eql(@config.name.downcase)
    end
  end

  context "private methods" do
    describe "#minter" do
      it "returns nil if no DOI services are active" do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: false))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: false))
        expect(described_class.send(:minter)).to eql(nil)
      end
      it "returns the first active service if all DOI services are active" do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: true))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: true))
        result = described_class.send(:minter)
        expect(result.name).to eql(ExternalApis::DataciteService.name)
      end
      it "returns the DataciteService is the only active service" do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: true))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: false))
        result = described_class.send(:minter)
        expect(result.name).to eql(ExternalApis::DataciteService.name)
      end
      it "returns the DmphubService is the only active service" do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: false))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: true))
        result = described_class.send(:minter)
        expect(result.name).to eql(ExternalApis::DmphubService.name)
      end
    end

    describe "#scheme(svc:)" do
      it "returns the existing IdentifierScheme associated with the service" do
        expect(described_class.send(:scheme, svc: @config)).to eql(@scheme)
      end
      it "creates the IdentifierScheme associated with the service" do
        scheme_count = IdentifierScheme.all.length
        @config.name = Faker::Lorem.unique.word
        result = described_class.send(:scheme, svc: @config)
        expect(IdentifierScheme.all.length).to eql(scheme_count + 1)
        expect(result.name).to eql(@config.name)
        expect(result.description).to eql(@config.description)
        expect(result.for_plans).to eql(true)
        expect(result.for_identification).to eql(true)
      end
    end
  end

end
