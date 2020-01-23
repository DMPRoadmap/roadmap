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
    context "#config" do
      it "returns the branding.yml config" do
        expected = Rails.application.config.branding
        expect(described_class.send(:config)).to eql(expected)
      end
    end
    context "#app_name" do
      it "defaults to the Rails.application.class.name" do
        Rails.configuration.branding[:application].delete(:name)
        expected = Rails.application.class.name
        expect(described_class.send(:app_name)).to eql(expected)
      end
      it "returns the application name defined in branding.yml" do
        Rails.configuration.branding[:application][:name] = "Foo"
        expect(described_class.send(:app_name)).to eql("Foo")
      end
    end
    context "#app_email" do
      it "defaults to the contact_us url" do
        Rails.configuration.branding[:organisation].delete(:helpdesk_email)
        expected = Rails.application.routes.url_helpers.contact_us_url
        expect(described_class.send(:app_email)).to eql(expected)
      end
      it "returns the help_desk email defined in branding.yml" do
        Rails.configuration.branding[:organisation][:helpdesk_email] = "Foo"
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
        expect(described_class.send(:http_get, uri: @uri).code).to eql("200")
      end
      it "follows redirects" do
        uri2 = "#{@uri}/redirected"
        stub_redirect(uri: @uri, redirect_to: uri2)
        stub_request(:get, uri2).with(headers: described_class.headers)
                                .to_return(status: 200, body: "", headers: {})

        resp = described_class.send(:http_get, uri: @uri)
        expect(resp.is_a?(Net::HTTPSuccess)).to eql(true)
      end
      it "does not allow more than the max number of redirects" do
        described_class.max_redirects.times.each do |i|
          stub_redirect(uri: "#{@uri}/redirect#{i}",
                        redirect_to: "#{@uri}/redirect#{i + 1}")
        end
        final_uri = "#{@uri}/redirect#{described_class.max_redirects}"
        stub_request(:get, final_uri).with(headers: described_class.headers)
                                     .to_return(status: 200, body: "", headers: {})

        resp = described_class.send(:http_get, uri: "#{@uri}/redirect0")
        expect(resp.is_a?(Net::HTTPRedirection)).to eql(true)
      end
    end

    context "#prep_http" do
      before(:each) do
        @uri = Faker::Internet.url
      end
      it "returns nil if no target is specified" do
        target, http = described_class.send(:prep_http, target: nil)
        expect(target).to eql(nil)
        expect(http).to eql(nil)
      end
      it "accomodates HTTP" do
        uri = @uri.gsub("https:", "http:")
        target, http = described_class.send(:prep_http, target: uri)
        expect(target).to eql(URI.parse(uri))
        expect(http.use_ssl?).to eql(false)
      end
      it "accomodates HTTPS" do
        uri = @uri.gsub("http:", "https:")
        target, http = described_class.send(:prep_http, target: uri)
        expect(target).to eql(URI.parse(uri))
        expect(http.use_ssl?).to eql(true)
      end
    end

    context "#prep_headers" do
      before(:each) do
        @headers = described_class.headers
        @req = Net::HTTP::Get.new(Faker::Internet.url)
      end
      it "returns nil if no Net request is specified" do
        expect(described_class.send(:prep_headers, request: nil)).to eql(nil)
      end
      it "allows additional headers" do
        hdrs = JSON.parse({ "Foo": Faker::Lorem.word }.to_json)
        req = described_class.send(:prep_headers, request: @req,
                                                  additional_headers: hdrs)
        expect(req["Foo"].present?).to eql(true)
      end
      it "allows base headers to be overwritten" do
        word = Faker::Lorem.word
        hdrs = JSON.parse({ "Accept": word }.to_json)
        req = described_class.send(:prep_headers, request: @req,
                                                  additional_headers: hdrs)
        expect(req["Accept"]).to eql(word)
      end
    end
  end

  def stub_redirect(uri:, redirect_to:)
    stub_request(:get, uri).with(headers: described_class.headers)
                           .to_return(status: 301, body: "",
                                      headers: { "Location": redirect_to })
  end
end
