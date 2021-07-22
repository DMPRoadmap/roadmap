# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExternalApis::BaseService do

  before(:each) do
    # The base service is meant to abstract, so spoof some config
    # variables here so that our tests can function
    described_class.stubs(:landing_page_url).returns(Faker::Internet.url)
    described_class.stubs(:api_base_url).returns(Faker::Internet.url)
  end

  describe "#headers" do
    before(:each) do
      @headers = described_class.headers
    end
    it "sets the Content-Type header for JSON" do
      expect(@headers[:"Content-Type"]).to eql("application/json")
    end
    it "sets the Accept header for JSON" do
      expect(@headers[:Accept]).to eql("application/json")
    end
    it "sets the User-Agent header for the default Application name and contact us url" do
      expected = "#{described_class.send(:app_name)}" \
                 " (#{described_class.send(:app_email)})"
      expect(@headers[:"User-Agent"]).to eql(expected)
    end
  end

  describe "#log_error" do
    before(:each) do
      @err = Exception.new(Faker::Lorem.sentence)
    end
    it "does not write to the log if method is undefined" do
      expect(described_class.log_error(method: nil, error: @err)).to eql(nil)
    end
    it "does not write to the log if error is undefined" do
      expect(described_class.log_error(method: Faker::Lorem.word, error: nil)).to eql(nil)
    end
    it "writes to the log" do
      Rails.logger.expects(:error).at_least(1)
      described_class.log_error(method: Faker::Lorem.word, error: @err)
    end
  end

  context "private methods" do
    context "#app_name" do
      it "defaults to the Rails.application.class.name" do
        Rails.configuration.x.application.delete(:name)
        expected = ApplicationService.application_name
        expect(described_class.send(:app_name)).to eql(expected)
      end
      it "returns the application name defined in dmproadmap.rb initializer" do
        Rails.configuration.x.application.name = "Foo"
        expect(described_class.send(:app_name)).to eql("foo")
      end
    end
    context "#app_email" do
      it "defaults to the contact_us url" do
        Rails.configuration.x.organisation.delete(:helpdesk_email)
        expected = Rails.application.routes.url_helpers.contact_us_url
        expect(described_class.send(:app_email)).to eql(expected)
      end
      it "returns the help_desk email defined in dmproadmap.rb initializer" do
        Rails.configuration.x.organisation.helpdesk_email = "Foo"
        expect(described_class.send(:app_email)).to eql("Foo")
      end
    end
    context "#http_get" do
      before(:each) do
        @uri = "http://example.org"
      end
      it "returns nil if no URI is specified" do
        expect(described_class.send(:http_get, uri: nil)).to eql(nil)
      end
      it "returns nil if an error occurs" do
        expect(described_class.send(:http_get, uri: "badurl~^(%")).to eql(nil)
      end
      it "logs an error if an error occurs" do
        Rails.logger.expects(:error).at_least(1)
        expect(described_class.send(:http_get, uri: "badurl~^(%")).to eql(nil)
      end
      it "returns an HTTP response" do
        stub_request(:get, @uri).with(headers: described_class.headers)
                                .to_return(status: 200, body: "", headers: {})
        expect(described_class.send(:http_get, uri: @uri).code).to eql(200)
      end
      it "follows redirects" do
        uri2 = "#{@uri}/redirected"
        stub_redirect(uri: @uri, redirect_to: uri2)
        stub_request(:get, uri2).with(headers: described_class.headers)
                                .to_return(status: 200, body: "", headers: {})

        resp = described_class.send(:http_get, uri: @uri)
        expect(resp.code).to eql(200)
      end
    end

    context "#options(additional_headers:, debug:)" do
      before(:each) do
        described_class.stubs(:headers).returns({ "Accept": "*/*" })
      end
      it "headers just include base headers if no :additional_headers" do
        result = described_class.send(:options)
        expect(result[:headers][:Accept]).to eql("*/*")
      end
      it "merges additonal headers into the :headers option" do
        result = described_class.send(:options, additional_headers: { foo: "bar" })
        expect(result[:headers][:Accept]).to eql("*/*")
        expect(result[:headers][:foo]).to eql("bar")
      end
      it "does not include :debug_output if :debug is false" do
        result = described_class.send(:options)
        expect(result[:debug_output]).to eql(nil)
      end
      it "includes :debug_output if :debug is true" do
        result = described_class.send(:options, additional_headers: {}, debug: true)
        expect(result[:debug_output].nil?).to eql(false)
      end
      it "includes :follow_redirects option" do
        result = described_class.send(:options)
        expect(result[:follow_redirects]).to eql(true)
      end
    end

  end

  def stub_redirect(uri:, redirect_to:)
    stub_request(:get, uri).with(headers: described_class.headers)
                           .to_return(status: 301, body: "",
                                      headers: { "Location": redirect_to })
  end
end
