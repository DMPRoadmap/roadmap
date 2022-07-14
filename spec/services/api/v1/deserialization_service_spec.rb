# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::DeserializationService do
  describe 'object_from_identifier(clazz:, json:)' do
    before(:each) do
      scheme = create(:identifier_scheme, name: 'ror')
      @org = create(:org)
      @clazz = @org.class.name
      @ror = create(:identifier, identifier_scheme: scheme, identifiable: @org)
      @url = create(:identifier, identifier_scheme: nil, identifiable: @org)
      @org.reload
      @ror_json = { type: @ror.identifier_scheme.name, identifier: @ror.value }
      @url_json = { type: 'URL', identifier: @url.value }
    end
    it 'returns nil if :class_name is not present' do
      expect(described_class.object_from_identifier(class_name: nil, json: @ror_json)).to eql(nil)
    end
    it 'returns nil if :json is not present' do
      expect(described_class.object_from_identifier(class_name: @clazz, json: nil)).to eql(nil)
    end
    it 'returns nil if :json[:type] is not present' do
      @ror_json.delete(:type)
      result = described_class.object_from_identifier(class_name: @clazz, json: @ror_json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :json[:identifier] is not present' do
      @ror_json.delete(:identifier)
      result = described_class.object_from_identifier(class_name: @clazz, json: @ror_json)
      expect(result).to eql(nil)
    end
    it 'returns nil if specified class is not Identifiable' do
      result = described_class.object_from_identifier(class_name: 'Section', json: @ror_json)
      expect(result).to eql(nil)
    end
    it 'returns nil if :class_name is not a known class' do
      result = described_class.object_from_identifier(class_name: 'Foo', json: @ror_json)
      expect(result).to eql(nil)
    end
    it 'returns nil if no record matched the identifier' do
      @ror_json[:identifier] = SecureRandom.uuid
      result = described_class.object_from_identifier(class_name: @clazz, json: @ror_json)
      expect(result).to eql(nil)
    end
    it 'returns the object for an identifier with an IdentifierScheme' do
      result = described_class.object_from_identifier(class_name: @clazz, json: @ror_json)
      expect(result).to eql(@org)
    end
    it 'returns nil for an identifier with no IdentifierScheme (e.g. URL)' do
      result = described_class.object_from_identifier(class_name: @clazz, json: @url_json)
      expect(result).to eql(nil)
    end
  end

  describe ':attach_identifier(object:, json:)' do
    before(:each) do
      @scheme = create(:identifier_scheme, name: 'ror')
      @object = build(:org)
      @json = { type: @scheme.name, identifier: SecureRandom.uuid }
    end

    it 'returns the object as-is if :object is not present' do
      expect(described_class.attach_identifier(object: nil, json: @json)).to eql(nil)
    end
    it 'returns the object as-is if :object is not Identifiable' do
      obj = Theme.new
      expect(described_class.attach_identifier(object: obj, json: @json)).to eql(obj)
    end
    it 'returns the object as-is if :json is not present' do
      expect(described_class.attach_identifier(object: @object, json: nil)).to eql(@object)
    end
    it 'returns the object as-is if :json[:type] is not present' do
      @json.delete(:type)
      expect(described_class.attach_identifier(object: @object, json: @json)).to eql(@object)
    end
    it 'returns the object as-is if :json[:identifier] is not present' do
      @json.delete(:identifier)
      expect(described_class.attach_identifier(object: @object, json: @json)).to eql(@object)
    end
    it 'returns the object as-is if :object already has an identifier for that scheme' do
      @object.identifiers << build(:identifier, identifier_scheme: @scheme,
                                                value: SecureRandom.uuid)
      expected = @object.identifiers.first.value
      result = described_class.attach_identifier(object: @object, json: @json)
      expect(result).to eql(@object)
      expect(result.identifiers.length).to eql(1)
      expect(result.identifiers.first.value).to eql(expected)
    end
    it 'attaches the identifier' do
      expected = "#{@scheme.identifier_prefix}#{@json[:identifier]}"
      result = described_class.attach_identifier(object: @object, json: @json)
      expect(result).to eql(@object)
      expect(result.identifiers.length).to eql(1)
      expect(result.identifiers.first.value).to eql(expected)
    end
  end

  describe ':translate_role(role:)' do
    before(:each) do
      @default = Contributor.role_default
      @role = "#{Contributor::ONTOLOGY_BASE_URL}/#{Contributor.new.all_roles.sample}"
    end

    it 'returns the default role if role is not present?' do
      expect(described_class.send(:translate_role, role: nil)).to eql(@default)
    end
    it 'returns the default role if role is not a valid/defined role' do
      result = described_class.send(:translate_role, role: Faker::Lorem.word)
      expect(result).to eql(@default)
    end
    it 'returns the role (when it includes the ONTOLOGY_BASE_URL)' do
      expected = @role.split('/').last
      expect(described_class.send(:translate_role, role: @role)).to eql(expected)
    end
    it 'returns the role (when it does not include the ONTOLOGY_BASE_URL)' do
      role = Contributor.new.all_roles.last.to_s
      expect(described_class.send(:translate_role, role: role)).to eql(role)
    end
  end

  describe ':app_extensions(json:)' do
    before(:each) do
      @template = create(:template)
    end

    it 'returns an empty hash is json is not present' do
      expect(described_class.send(:app_extensions, json: nil)).to eql({})
    end
    it 'returns an empty hash is json :extended_attributes is not present' do
      json = { title: Faker::Lorem.sentence }
      expect(described_class.send(:app_extensions, json: json)).to eql({})
    end
    it 'returns an empty hash if there is no extension for the current application' do
      expected = { template: { id: @template.id } }
      # ApplicationService.expects('dmproadmap').returns('tester')
      json = { extension: [{ foo: expected }] }
      expect(described_class.send(:app_extensions, json: json)).to eql({})
    end
    it 'returns the hash for the current application' do
      expected = { template: { id: @template.id } }
      json = { extension: [{ dmproadmap: expected }] }
      result = described_class.send(:app_extensions, json: json)
      expect(result).to eql(expected)
    end
  end

  describe 'doi?(value:)' do
    before(:each) do
      @scheme = create(:identifier_scheme, name: 'doi',
                                           identifier_prefix: Faker::Internet.url)
    end

    it 'returns false if value is not present' do
      expect(described_class.send(:doi?, value: nil)).to eql(false)
    end
    it 'returns false if the value does not match ARK or DOI pattern' do
      url = Faker::Internet.url
      expect(described_class.send(:doi?, value: url)).to eql(false)
    end
    it 'returns false if the value does not match a partial ARK/DOI pattern' do
      val = '23645gy3d'
      expect(described_class.send(:doi?, value: val)).to eql(false)
      val = '10.999'
      expect(described_class.send(:doi?, value: val)).to eql(false)
    end
    it "returns false if there is no 'doi' identifier scheme" do
      val = '10.999/23645gy3d'
      @scheme.destroy
      expect(described_class.send(:doi?, value: val)).to eql(false)
    end
    it "returns false if 'doi' identifier scheme exists but value is not doi" do
      expect(described_class.send(:doi?, value: SecureRandom.uuid)).to eql(false)
    end
    it 'returns true (identifier only)' do
      val = '10.999/23645gy3d'
      expect(described_class.send(:doi?, value: val)).to eql(true)
    end
    it 'returns true (fully qualified ARK/DOI url)' do
      url = "#{Faker::Internet.url}/10.999/23645gy3d"
      expect(described_class.send(:doi?, value: url)).to eql(true)
    end
  end

  describe ':safe_date(value:)' do
    it 'returns nil if :value is not a String' do
      expect(described_class.safe_date(value: 123)).to eql(nil)
      expect(described_class.safe_date(value: Date.today)).to eql(nil)
    end
    it 'returns the :value as a string if it is not parsable by Time' do
      expect(described_class.safe_date(value: 'foo')).to eql('foo')
    end
    it 'converts :value to a UTC format' do
      now = Time.now
      expected = '2020-11-11'
      rslt = described_class.safe_date(value: '2020-11-11')
      expect(rslt.getlocal.to_s.start_with?(expected)).to eql(true)
      expect(rslt.to_s.end_with?('UTC')).to eql(true)
      rslt = described_class.safe_date(value: 'November 11, 2020')
      expect(rslt.getlocal.to_s.start_with?(expected)).to eql(true)
      expect(rslt.to_s.end_with?('UTC')).to eql(true)
      rslt = described_class.safe_date(value: 'Nov. 11 2020')
      expect(rslt.getlocal.to_s.start_with?(expected)).to eql(true)
      expect(rslt.to_s.end_with?('UTC')).to eql(true)
      rslt = described_class.safe_date(value: '11 Nov. 2020')
      expect(rslt.getlocal.to_s.start_with?(expected)).to eql(true)
      expect(rslt.to_s.end_with?('UTC')).to eql(true)
      rslt = described_class.safe_date(value: '2020-11-11 10:15:35 PST')
      expect(rslt.to_s.start_with?(expected)).to eql(true)
      expect(rslt.to_s.end_with?('UTC')).to eql(true)
      expected = now.utc.to_s
      expect(described_class.safe_date(value: now.to_formatted_s(:iso8601)).to_s).to eql(expected)
    end
  end
end
