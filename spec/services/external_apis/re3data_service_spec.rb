# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::Re3dataService do
  before(:each) do
    @repo_id = "r3d#{Faker::Number.number(digits: 6)}"
    @headers = described_class.headers
    @repositories_path = "#{described_class.api_base_url}#{described_class.list_path}"
    path = "#{described_class.api_base_url}#{described_class.repository_path}#{@repo_id}"
    @repository_path = URI(path)

    @repositories_results = <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <list>
        <repository>
          <id>#{@repo_id}</id>
          <name>#{Faker::Company.name}</name>
          <link href="#{@repo_id}" rel="self"/>
        </repository>
      </list>
    XML
    @repository_result = <<-XML
      <?xml version="1.0" encoding="utf-8"?>
      <!--re3data.org Schema for the Description of Research Data Repositories. Version 2.2, December 2014. doi:10.2312/re3.006-->
      <r3d:re3data xmlns:r3d="http://www.re3data.org/schema/2-2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.re3data.org/schema/2-2 http://schema.re3data.org/2-2/re3dataV2-2.xsd">
        <r3d:repository>
          <r3d:re3data.orgIdentifier>#{@repo_id}</r3d:re3data.orgIdentifier>
          <r3d:repositoryName language="eng">#{Faker::Lorem.word.upcase}</r3d:repositoryName>
          <r3d:repositoryURL>#{Faker::Internet.url}</r3d:repositoryURL>
          <r3d:repositoryIdentifier>#{Faker::Lorem.word}:#{Faker::Number.number(digits: 5)}</r3d:repositoryIdentifier>
          <r3d:description language="eng">#{Faker::Lorem.sentence}</r3d:description>
          <r3d:repositoryContact>#{Faker::Internet.email}</r3d:repositoryContact>
          <r3d:type>#{%w[disciplinary institutional other].sample}</r3d:type>
          <r3d:size updated="2021-02-02">#{Faker::Number.number(digits: 4)} data packages</r3d:size>
          <r3d:startDate>2021</r3d:startDate>
          <r3d:endDate></r3d:endDate>
          <r3d:repositoryLanguage>eng</r3d:repositoryLanguage>
          <r3d:subject subjectScheme="DFG">1 Humanities and Social Sciences</r3d:subject>
          <r3d:missionStatementURL>#{Faker::Internet.url}</r3d:missionStatementURL>
          <r3d:contentType contentTypeScheme="parse">Plain text</r3d:contentType>
          <r3d:providerType>dataProvider</r3d:providerType>
          <r3d:keyword>#{Faker::Lorem.word}</r3d:keyword>
          <r3d:institution>
            <r3d:institutionName language="eng">#{Faker::Company.name}</r3d:institutionName>
              <r3d:institutionAdditionalName language="eng">#{Faker::Lorem.word.upcase}</r3d:institutionAdditionalName>
              <r3d:institutionCountry>USA</r3d:institutionCountry>
              <r3d:responsibilityType>general</r3d:responsibilityType>
              <r3d:institutionType>non-profit</r3d:institutionType>
              <r3d:institutionURL>#{Faker::Internet.url}</r3d:institutionURL>
              <r3d:responsibilityStartDate>2021</r3d:responsibilityStartDate>
              <r3d:responsibilityEndDate></r3d:responsibilityEndDate>
            </r3d:institution>
          <r3d:institution>
          <r3d:policy>
            <r3d:policyName>#{Faker::Lorem.sentence}</r3d:policyName>
            <r3d:policyURL>#{Faker::Internet.url}</r3d:policyURL>
          </r3d:policy>
          <r3d:databaseAccess><r3d:databaseAccessType>#{%w[open restricted closed].sample}</r3d:databaseAccessType></r3d:databaseAccess>
          <r3d:databaseLicense>
            <r3d:databaseLicenseName>#{Faker::Lorem.word}</r3d:databaseLicenseName>
            <r3d:databaseLicenseURL>#{Faker::Internet.url}</r3d:databaseLicenseURL>
          </r3d:databaseLicense>
          <r3d:dataAccess><r3d:dataAccessType>#{Faker::Lorem.word}</r3d:dataAccessType></r3d:dataAccess>
          <r3d:dataLicense>
            <r3d:dataLicenseName>#{Faker::Lorem.word}</r3d:dataLicenseName>
            <r3d:dataLicenseURL>#{Faker::Internet.url}</r3d:dataLicenseURL>
          </r3d:dataLicense>
          <r3d:dataUpload>
            <r3d:dataUploadType>#{Faker::Lorem.word}</r3d:dataUploadType>
            <r3d:dataUploadRestriction>#{Faker::Lorem.word}</r3d:dataUploadRestriction>
          </r3d:dataUpload>
          <r3d:dataUploadLicense>
            <r3d:dataUploadLicenseName>#{Faker::Lorem.word}</r3d:dataUploadLicenseName>
            <r3d:dataUploadLicenseURL>#{Faker::Internet.url}</r3d:dataUploadLicenseURL>
          </r3d:dataUploadLicense>
          <r3d:software><r3d:softwareName>#{Faker::Lorem.word}</r3d:softwareName></r3d:software>
          <r3d:versioning>#{%w[no yes].sample}</r3d:versioning>
          <r3d:api apiType="#{Faker::Lorem.word}">#{Faker::Internet.url}</r3d:api>
          <r3d:pidSystem>#{%w[ARK DOI handle].sample}</r3d:pidSystem>
          <r3d:citationGuidelineURL>#{Faker::Internet.url}</r3d:citationGuidelineURL>
          <r3d:aidSystem>#{Faker::Lorem.word.upcase}</r3d:aidSystem>
          <r3d:enhancedPublication>#{%w[no yes].sample}</r3d:enhancedPublication>
          <r3d:qualityManagement>#{%w[no yes].sample}</r3d:qualityManagement>
          <r3d:metadataStandard>
            <r3d:metadataStandardName metadataStandardScheme="#{Faker::Lorem.word}">#{Faker::Lorem.sentence}</r3d:metadataStandardName>
            <r3d:metadataStandardURL>#{Faker::Internet.url}</r3d:metadataStandardURL>
          </r3d:metadataStandard>
          <r3d:remarks>#{Faker::Lorem.sentence}</r3d:remarks>
          <r3d:entryDate>2021-02-03</r3d:entryDate>
          <r3d:lastUpdate>2021-02-03</r3d:lastUpdate>
        </r3d:repository>
      </r3d:re3data>
    XML
  end

  describe '#fetch' do
    context '#fetch' do
      it 'returns an empty array if re3data did not return a repository list' do
        described_class.expects(:query_re3data).returns(nil)
        expect(described_class.fetch).to eql([])
      end
      it 'fetches individual repository data' do
        described_class.expects(:query_re3data)
                       .returns(Nokogiri::XML(@repositories_results, nil, 'utf8'))
        described_class.expects(:query_re3data_repository).at_least(1)
        described_class.fetch
      end
      it 'processes the repository data' do
        described_class.expects(:query_re3data)
                       .returns(Nokogiri::XML(@repositories_results, nil, 'utf8'))
        described_class.expects(:query_re3data_repository)
                       .returns(Nokogiri::XML(@repository_result, nil, 'utf8'))
        described_class.expects(:process_repository).at_least(1)
        described_class.fetch
      end
    end
  end

  context 'private methods' do
    describe '#query_re3data' do
      it 'calls the handle_http_failure method if a non 200 response is received' do
        stub_request(:get, @repositories_path).with(headers: @headers)
                                              .to_return(status: 403, body: '', headers: {})
        described_class.expects(:handle_http_failure).at_least(1)
        expect(described_class.send(:query_re3data)).to eql(nil)
      end
      it 'returns the response body as XML' do
        stub_request(:get, @repositories_path).with(headers: @headers)
                                              .to_return(
                                                status: 200,
                                                body: @repositories_results,
                                                headers: {}
                                              )
        expected = Nokogiri::XML(@repositories_results, nil, 'utf8').text
        expect(described_class.send(:query_re3data).text).to eql(expected)
      end
    end

    describe '#query_re3data_repository(repo_id:)' do
      it 'returns an empty array if term is blank' do
        expect(described_class.send(:query_re3data_repository, repo_id: nil)).to eql([])
      end
      it 'calls the handle_http_failure method if a non 200 response is received' do
        stub_request(:get, @repository_path).with(headers: @headers)
                                            .to_return(status: 403, body: '', headers: {})
        described_class.expects(:handle_http_failure).at_least(1)
        expect(described_class.send(:query_re3data_repository, repo_id: @repo_id)).to eql([])
      end
      it 'returns the response body as JSON' do
        stub_request(:get, @repository_path).with(headers: @headers)
                                            .to_return(
                                              status: 200,
                                              body: @repository_result,
                                              headers: {}
                                            )
        expected = Nokogiri::XML(@repository_result, nil, 'utf8').text
        result = described_class.send(:query_re3data_repository, repo_id: @repo_id).text
        expect(result).to eql(expected)
      end
    end

    describe '#process_repository(id:, node:)' do
      before(:each) do
        @node = Nokogiri::XML(@repository_result, nil, 'utf8')
        @repo = @node.xpath('//r3d:re3data//r3d:repository').first
      end
      it 'returns nil if :id is not present' do
        expect(described_class.send(:process_repository, id: nil, node: @repo)).to eql(nil)
      end
      it 'returns nil if :node is not present' do
        expect(described_class.send(:process_repository, id: @repo_id, node: nil)).to eql(nil)
      end
      it 'finds an existing Repository by its identifier' do
        repo = create(:repository, uri: @repo_id)
        expect(described_class.send(:process_repository, id: @repo_id, node: @repo)).to eql(repo)
      end
      it 'finds an existing Repository by its homepage' do
        repo = create(:repository, homepage: @repo.xpath('//r3d:repositoryURL')&.text)
        expect(described_class.send(:process_repository, id: @repo_id, node: @repo)).to eql(repo)
      end
      it 'creates a new Repository' do
        repo = described_class.send(:process_repository, id: @repo_id, node: @repo)
        expect(repo.new_record?).to eql(false)
        expect(repo.name).to eql(@repo.xpath('//r3d:repositoryName')&.text)
      end
      it 'attaches the identifier to the Repository (if it is not already defined' do
        repo = described_class.send(:process_repository, id: @repo_id, node: @repo)
        expect(repo.uri.ends_with?(@repo_id)).to eql(true)
      end
    end

    describe '#parse_repository(repo:, node:)' do
      before(:each) do
        doc = Nokogiri::XML(@repository_result, nil, 'utf8')
        @node = doc.xpath('//r3d:re3data//r3d:repository').first
        @repo = create(:repository, name: @node.xpath('//r3d:repositoryName')&.text)
      end
      it 'returns nil if :repo is not present' do
        expect(described_class.send(:parse_repository, repo: nil, node: @node)).to eql(nil)
      end
      it 'returns nil if :node is not present' do
        expect(described_class.send(:parse_repository, repo: @repo, node: nil)).to eql(nil)
      end
      it 'updates the :description' do
        described_class.send(:parse_repository, repo: @repo, node: @node)
        expect(@repo.description).to eql(@node.xpath('//r3d:description')&.text)
      end
      it 'updates the :homepage' do
        described_class.send(:parse_repository, repo: @repo, node: @node)
        expect(@repo.homepage).to eql(@node.xpath('//r3d:repositoryURL')&.text)
      end
      it 'updates the :contact' do
        described_class.send(:parse_repository, repo: @repo, node: @node)
        expect(@repo.contact).to eql(@node.xpath('//r3d:repositoryContact')&.text)
      end
      it 'updates the :info' do
        described_class.send(:parse_repository, repo: @repo, node: @node)
        expect(@repo.info.present?).to eql(true)
      end
      context ':info JSON content' do
        before(:each) do
          policies = @node.xpath('//r3d:policy').map do |node|
            described_class.send(:parse_policy, node: node)
          end
          upload_types = @node.xpath('//r3d:dataUpload').map do |node|
            described_class.send(:parse_upload, node: node)
          end

          @expected = {
            types: @node.xpath('//r3d:type').map(&:text),
            subjects: @node.xpath('//r3d:subject').map(&:text),
            provider_types: @node.xpath('//r3d:providerType').map(&:text),
            keywords: @node.xpath('//r3d:keyword').map(&:text),
            access: @node.xpath('//r3d:databaseAccess//r3d:databaseAccessType')&.text,
            pid_system: @node.xpath('//r3d:pidSystem')&.text,
            policies: policies,
            upload_types: upload_types
          }
        end
        it 'updates the :types' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['types']).to eql(@expected[:types])
        end
        it 'updates the :subjects' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['subjects']).to eql(@expected[:subjects])
        end
        it 'updates the :provider_types' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['provider_types']).to eql(@expected[:provider_types])
        end
        it 'updates the :keywords' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['keywords']).to eql(@expected[:keywords])
        end
        it 'updates the :access' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['access']).to eql(@expected[:access])
        end
        it 'updates the :pid_system' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['pid_system']).to eql(@expected[:pid_system])
        end
        it 'updates the :policies' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['policies'].to_json).to eql(@expected[:policies].to_json)
        end
        it 'updates the :upload_types' do
          described_class.send(:parse_repository, repo: @repo, node: @node)
          expect(@repo.info['upload_types'].to_json).to eql(@expected[:upload_types].to_json)
        end
      end
    end

    describe '#parse_policy(node:)' do
      before(:each) do
        @node = Nokogiri::XML(@repository_result, nil, 'utf8')
        base = @node.xpath('//r3d:re3data//r3d:repository').first
        @expected = {
          name: base.xpath('r3d:policyName')&.text,
          url: base.xpath('r3d:policyURL')&.text
        }
      end
      it 'returns nil if :node is not present' do
        expect(described_class.send(:parse_policy, node: nil)).to eql(nil)
      end
      it 'updates the :name' do
        expect(described_class.send(:parse_policy, node: @node)[:name]).to eql(@expected[:name])
      end
      it 'updates the :url' do
        expect(described_class.send(:parse_policy, node: @node)[:url]).to eql(@expected[:url])
      end
    end

    describe '#parse_upload(node:)' do
      before(:each) do
        @node = Nokogiri::XML(@repository_result, nil, 'utf8')
        base = @node.xpath('//r3d:re3data//r3d:repository').first
        @expected = {
          type: base.xpath('r3d:dataUploadType')&.text,
          restriction: base.xpath('r3d:dataUploadRestriction')&.text
        }
      end
      it 'returns nil if :node is not present' do
        expect(described_class.send(:parse_upload, node: nil)).to eql(nil)
      end
      it 'updates the :type' do
        expect(described_class.send(:parse_upload, node: @node)[:type]).to eql(@expected[:type])
      end
      it 'updates the :restriction' do
        result = described_class.send(:parse_upload, node: @node)[:restriction]
        expect(result).to eql(@expected[:restriction])
      end
    end
  end
end
