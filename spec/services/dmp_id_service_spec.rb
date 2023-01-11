# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DmpIdService do
  include Helpers::ConfigHelper

  before do
    @original_enabled = Rails.configuration.x.madmp.enable_dmp_id_registration
    @original_name = Rails.configuration.x.datacite.name
    @original_active = Rails.configuration.x.datacite.active
    @original_desc = Rails.configuration.x.datacite.description
    @orignal_landing = Rails.configuration.x.datacite.landing_page_url

    Rails.configuration.x.madmp.enable_dmp_id_registration = true

    # Using Datacite for these tests
    Rails.configuration.x.datacite.active = true
    Rails.configuration.x.datacite.name = 'datacite'
    Rails.configuration.x.datacite.description = Faker::Lorem.sentence
    Rails.configuration.x.datacite.landing_page_url = "#{Faker::Internet.url}/"

    @scheme = create(
      :identifier_scheme,
      name: Rails.configuration.x.datacite.name,
      identifier_prefix: Rails.configuration.x.datacite.landing_page_url,
      description: Rails.configuration.x.datacite.description,
      for_plans: true
    )
  end

  after do
    Rails.configuration.x.madmp.enable_dmp_id_registration = @original_enabled
    Rails.configuration.x.datacite.name = @original_name
    Rails.configuration.x.datacite.active = @original_active
    Rails.configuration.x.datacite.description = @original_desc
    Rails.configuration.x.datacite.landing_page_url = @orignal_landing
  end

  describe '#mint_dmp_id(plan:)' do
    before do
      @plan = build(:plan)
      @dmp_id = SecureRandom.uuid
      @qualified_dmp_id = "#{Rails.configuration.x.datacite.landing_page_url}#{@dmp_id}"
      stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: true))
    end

    it 'returns nil if :plan is not present' do
      expect(described_class.mint_dmp_id(plan: nil)).to be_nil
    end

    it 'returns nil if :plan is not an instance of Plan' do
      expect(described_class.mint_dmp_id(plan: build(:org))).to be_nil
    end

    it 'returns the existing DMP ID if :plan already has a :dmp_id' do
      existing = build(:identifier, identifier_scheme: @scheme, value: @qualified_dmp_id)
      ExternalApis::DataciteService.stubs(:mint_dmp_id)
                                   .returns(existing.value_without_scheme_prefix)
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      expect(described_class.mint_dmp_id(plan: @plan).value).to eql(existing.value)
    end

    it 'returns nil if if no DMP ID minting service is active' do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.mint_dmp_id(plan: @plan)).to be_nil
    end

    it 'returns nil if the DMP ID minting service did not receive a DMP ID' do
      ExternalApis::DataciteService.stubs(:mint_dmp_id).returns(nil)
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      expect(described_class.mint_dmp_id(plan: @plan)).to be_nil
    end

    it 'returns the DMP ID retrieved by the DMP ID minting service' do
      ExternalApis::DataciteService.stubs(:mint_dmp_id).returns(@qualified_dmp_id)
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      expect(described_class.mint_dmp_id(plan: @plan).value).to eql(@qualified_dmp_id)
    end

    it 'prepends the :landing_page_url if the DMP ID is not a URL' do
      ExternalApis::DataciteService.stubs(:mint_dmp_id).returns(@dmp_id)
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      expect(described_class.mint_dmp_id(plan: @plan).value).to eql(@qualified_dmp_id)
    end

    it 'does not prepend the :landing_page_url if the DMP ID is already a URL' do
      ExternalApis::DataciteService.stubs(:mint_dmp_id).returns(@qualified_dmp_id)
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      described_class.stubs(:scheme).returns(@scheme)
      expected = "#{@scheme.identifier_prefix}#{@qualified_dmp_id}"
      expect(described_class.mint_dmp_id(plan: @plan).value).not_to eql(expected)
    end
  end

  describe '#minting_service_defined?' do
    it 'returns false if no DMP ID minting service is active' do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.minting_service_defined?).to be(false)
    end

    it 'returns true if a DMP ID minting service is active' do
      ExternalApis::DataciteService.stubs(:api_base_url).returns(Faker::Internet.url)
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      expect(described_class.minting_service_defined?).to be(true)
    end
  end

  describe '#identifier_scheme' do
    it 'returns nil if there is no active DMP ID minting service' do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.identifier_scheme).to be_nil
    end

    it 'returns the IdentifierScheme associated with the DMP ID minting service' do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      stub_x_section(section_sym: :datacite,
                     open_struct: OpenStruct.new(active: true, name: @scheme.name))
      expect(described_class.identifier_scheme).to eql(@scheme)
    end

    it 'creates the IdentifierScheme if one is not defined for the DMP ID minting service' do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      stub_x_section(section_sym: :datacite,
                     open_struct: OpenStruct.new(active: true, name: 'datacite'))
      expect(described_class.identifier_scheme).to eql(@scheme)
    end
  end

  describe '#scheme_callback_uri' do
    it 'returns nil if there is no DMP ID minting service' do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.scheme_callback_uri).to be_nil
    end

    it 'returns nil if the callback_uri is not defined by the service' do
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      stub_x_section(section_sym: :datacite,
                     open_struct: OpenStruct.new(active: true, callback_path: nil))
      expect(described_class.scheme_callback_uri).to be_nil
    end

    it 'returns the callback_uri' do
      uri = Faker::Internet.url
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      stub_x_section(section_sym: :datacite,
                     open_struct: OpenStruct.new(active: true, callback_path: uri))
      described_class.stubs(:minter).returns(ExternalApis::DataciteService)
      expect(described_class.scheme_callback_uri).to eql(uri)
    end
  end

  describe '#landing_page_url' do
    it 'returns nil if there is no DMP ID minting service' do
      described_class.stubs(:minter).returns(nil)
      expect(described_class.landing_page_url).to be_nil
    end

    it 'returns nil if the landing_page is not defined by the service' do
      described_class.stubs(:minter).returns(ExternalApis::DmphubService)
      stub_x_section(section_sym: :dmphub,
                     open_struct: OpenStruct.new(active: true, landing_page_url: nil))
      expect(described_class.landing_page_url).to be_nil
    end

    it 'returns the landing_page' do
      uri = Faker::Internet.url
      described_class.stubs(:minter).returns(ExternalApis::DmphubService)
      stub_x_section(section_sym: :dmphub,
                     open_struct: OpenStruct.new(active: true, landing_page_url: uri))
      described_class.stubs(:minter).returns(ExternalApis::DmphubService)
      expect(described_class.landing_page_url).to eql(uri)
    end
  end

  context 'private methods' do
    describe '#minter' do
      it 'returns nil if no DMP ID services are active' do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: false))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: false))
        expect(described_class.send(:minter)).to be_nil
      end

      it 'returns the first active service if all DMP ID services are active' do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: true))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: true))
        result = described_class.send(:minter)
        expect(result.name).to eql(ExternalApis::DataciteService.name)
      end

      it 'returns the DataciteService is the only active service' do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: true))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: false))
        result = described_class.send(:minter)
        expect(result.name).to eql(ExternalApis::DataciteService.name)
      end

      it 'returns the DmphubService is the only active service' do
        stub_x_section(section_sym: :datacite, open_struct: OpenStruct.new(active: false))
        stub_x_section(section_sym: :dmphub, open_struct: OpenStruct.new(active: true))
        result = described_class.send(:minter)
        expect(result.name).to eql(ExternalApis::DmphubService.name)
      end
    end
  end
end
