# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::BaseService do
  before do
    # The base service is meant to abstract, so spoof some config
    # variables here so that our tests can function
    described_class.stubs(:landing_page_url).returns(Faker::Internet.url)
    described_class.stubs(:api_base_url).returns(Faker::Internet.url)
  end

  describe '#headers' do
    before do
      @headers = described_class.headers
    end

    it 'sets the Content-Type header for JSON' do
      expect(@headers[:'Content-Type']).to eql('application/json')
    end

    it 'sets the Accept header for JSON' do
      expect(@headers[:Accept]).to eql('application/json')
    end

    it 'sets the User-Agent header for the default Application name and contact us url' do
      expected = "#{described_class.send(:app_name)} " \
                 "(#{described_class.send(:app_email)})"
      expect(@headers[:'User-Agent']).to eql(expected)
    end
  end

  describe '#handle_http_failure(method:, http_response:)' do
    before do
      @resp = OpenStruct.new({ code: 500, body: 'It failed', headers: { foo: 'bar' } })
    end

    it 'works if method is not specified' do
      described_class.expects(:log_error).returns(true)
      expect(described_class.send(:handle_http_failure, method: nil, http_response: @resp))
    end

    it 'works if http_response is not present' do
      described_class.expects(:log_error).returns(true)
      expect(described_class.send(:handle_http_failure, method: :get, http_response: nil))
    end

    it 'logs the failure' do
      described_class.expects(:log_error).returns(true)
      expect(described_class.send(:handle_http_failure, method: :get, http_response: @resp))
    end
  end

  describe '#handle_uri_failure(method:, uri:)' do
    before do
      @uri = Faker::Internet.url
    end

    it 'works if method is not specified' do
      described_class.expects(:log_error).returns(true)
      expect(described_class.send(:handle_uri_failure, method: nil, uri: @uri))
    end

    it 'works if uri is not present' do
      described_class.expects(:log_error).returns(true)
      expect(described_class.send(:handle_uri_failure, method: :get, uri: nil))
    end

    it 'logs the failure' do
      described_class.expects(:log_error).returns(true)
      expect(described_class.send(:handle_uri_failure, method: :get, uri: @uri))
    end
  end

  describe '#log_error' do
    before do
      @err = Exception.new(Faker::Lorem.sentence)
    end

    it 'does not write to the log if method is undefined' do
      expect(described_class.log_error(method: nil, error: @err)).to be_nil
    end

    it 'does not write to the log if error is undefined' do
      expect(described_class.log_error(method: Faker::Lorem.word, error: nil)).to be_nil
    end

    it 'writes to the log' do
      Rails.logger.expects(:error).at_least(1)
      described_class.log_error(method: Faker::Lorem.word, error: @err)
    end
  end

  describe '#notify_administrators(obj:, response: nil, error: nil)' do
    before do
      @resp = OpenStruct.new({ code: 500, body: 'It failed', headers: { foo: 'bar' } })
      @err = StandardError.new('It failed!')
      @obj = build(:org)
    end

    it 'returns false if :obj is not present' do
      result = described_class.notify_administrators(obj: nil, response: @resp, error: @err)
      expect(result).to be(false)
    end

    it 'returns false if :response is not present' do
      result = described_class.notify_administrators(obj: @obj, response: nil, error: @err)
      expect(result).to be(false)
    end

    it 'sends the email if :error is not present' do
      result = described_class.notify_administrators(obj: @obj, response: @resp, error: nil)
      expect(result).to be(true)
    end

    it 'sends the email' do
      result = described_class.notify_administrators(obj: @obj, response: @resp, error: @err)
      expect(result).to be(true)
    end
  end

  context 'private methods' do
    describe '#app_name' do
      it 'defaults to the Rails.application.class.name' do
        Rails.configuration.x.application.delete(:name)
        expected = ApplicationService.application_name
        expect(described_class.send(:app_name)).to eql(expected)
      end

      it 'returns the application name defined in dmproadmap.rb initializer' do
        Rails.configuration.x.application.name = 'Foo'
        expect(described_class.send(:app_name)).to eql('Foo')
      end
    end

    describe '#app_email' do
      it 'defaults to the contact_us url' do
        helpdesk_email = Rails.configuration.x.organisation.helpdesk_email
        Rails.configuration.x.organisation.delete(:helpdesk_email)
        expected = Rails.application.routes.url_helpers.contact_us_url
        expect(described_class.send(:app_email)).to eql(expected)
        # Set it back so we don't mess up other tests!
        Rails.configuration.x.organisation.helpdesk_email = helpdesk_email
      end

      it 'returns the help_desk email defined in dmproadmap.rb initializer' do
        expect(described_class.send(:app_email)).to eql(Rails.configuration.x.organisation.helpdesk_email)
      end
    end

    describe '#http_get' do
      before do
        @uri = 'http://example.org'
      end

      it 'returns nil if no URI is specified' do
        expect(described_class.send(:http_get, uri: nil)).to be_nil
      end

      it 'returns nil if a URI error occurs' do
        described_class.expects(:handle_uri_failure).returns(true)
        expect(described_class.send(:http_get, uri: 'badurl~^(%')).to be_nil
      end

      it 'logs an error if an error occurs' do
        HTTParty.expects(:get).raises(HTTParty::Error.new)
        described_class.expects(:handle_http_failure).returns(true)
        expect(described_class.send(:http_get, uri: @uri)).to be_nil
      end

      it 'returns an HTTP response' do
        stub_request(:get, @uri).with(headers: described_class.headers)
                                .to_return(status: 200, body: '', headers: {})
        expect(described_class.send(:http_get, uri: @uri).code).to be(200)
      end

      it 'follows redirects' do
        uri2 = "#{@uri}/redirected"
        stub_redirect(uri: @uri, redirect_to: uri2)
        stub_request(:get, uri2).with(headers: described_class.headers)
                                .to_return(status: 200, body: '', headers: {})

        resp = described_class.send(:http_get, uri: @uri)
        expect(resp.code).to be(200)
      end
    end

    describe '#http_post' do
      before do
        @uri = 'http://example.org'
      end

      it 'returns nil if no URI is specified' do
        expect(described_class.send(:http_post, uri: nil)).to be_nil
      end

      it 'returns nil if a URI error occurs' do
        described_class.expects(:handle_uri_failure).returns(true)
        expect(described_class.send(:http_post, uri: 'badurl~^(%')).to be_nil
      end

      it 'logs an error if an error occurs' do
        HTTParty.expects(:post).raises(HTTParty::Error.new)
        described_class.expects(:handle_http_failure).returns(true)
        expect(described_class.send(:http_post, uri: 'badurl~^(%')).to be_nil
      end

      it 'returns an HTTP response' do
        described_class.expects(:options).returns({ headers: { foo: 'bar' } })
        stub_request(:post, @uri).with(headers: { foo: 'bar' })
                                 .to_return(status: 201, body: '', headers: {})
        expect(described_class.send(:http_post, uri: @uri).code).to be(201)
      end
    end

    describe '#http_put' do
      before do
        @uri = 'http://example.org'
      end

      it 'returns nil if no URI is specified' do
        expect(described_class.send(:http_put, uri: nil)).to be_nil
      end

      it 'returns nil if a URI error occurs' do
        described_class.expects(:handle_uri_failure).returns(true)
        expect(described_class.send(:http_put, uri: 'badurl~^(%')).to be_nil
      end

      it 'logs an error if an error occurs' do
        HTTParty.expects(:put).raises(HTTParty::Error.new)
        described_class.expects(:handle_http_failure).returns(true)
        expect(described_class.send(:http_put, uri: 'badurl~^(%')).to be_nil
      end

      it 'returns an HTTP response' do
        described_class.expects(:options).returns({ headers: { foo: 'bar' } })
        stub_request(:put, @uri).with(headers: { foo: 'bar' })
                                .to_return(status: 200, body: '', headers: {})
        expect(described_class.send(:http_put, uri: @uri).code).to be(200)
      end
    end

    describe '#options(additional_headers:, debug:)' do
      before do
        described_class.stubs(:headers).returns({ Accept: '*/*' })
      end

      it 'headers just include base headers if no :additional_headers' do
        result = described_class.send(:options)
        expect(result[:headers][:Accept]).to eql('*/*')
      end

      it 'merges additonal headers into the :headers option' do
        result = described_class.send(:options, additional_headers: { foo: 'bar' })
        expect(result[:headers][:Accept]).to eql('*/*')
        expect(result[:headers][:foo]).to eql('bar')
      end

      it 'does not include :debug_output if :debug is false' do
        result = described_class.send(:options)
        expect(result[:debug_output]).to be_nil
      end

      it 'includes :debug_output if :debug is true' do
        result = described_class.send(:options, additional_headers: {}, debug: true)
        expect(result[:debug_output].nil?).to be(false)
      end

      it 'includes :follow_redirects option' do
        result = described_class.send(:options)
        expect(result[:follow_redirects]).to be(true)
      end
    end
  end

  def stub_redirect(uri:, redirect_to:, method: :get)
    stub_request(method, uri).with(headers: described_class.headers)
                             .to_return(status: 301, body: '',
                                        headers: { Location: redirect_to })
  end
end
