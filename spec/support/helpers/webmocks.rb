# frozen_string_literal: true

module Webmocks
  def stub_ror_service
    url = ExternalApis::RorService.api_base_url
    headers = ExternalApis::RorService.headers

    # Mock the results of the ping/heartbeat check
    stub_request(:get, "#{url}#{ExternalApis::RorService.heartbeat_path}")
      .with(headers: headers).to_return(status: 200, body: 'OK', headers: {})

    # Mock the results of a search. We are only returning the elements of the
    # ROR response that we actually care about here
    stub_request(:get, /#{url}#{ExternalApis::RorService.search_path}\.*/)
      .with(headers: headers)
      .to_return(status: 200, body: mocked_ror_response, headers: {})
  end

  def stub_spdx_service(successful = true, response_body = "")
    stub_request(:get, %r{https://raw.githubusercontent.com/spdx/.*})
      .to_return(status: successful ? 200 : 500, body: response_body, headers: {})
  end

  def stub_rdamsc_service(successful = true, response_body = "")
    stub_request(:get, %r{https://rdamsc.bath.ac.uk/.*})
      .to_return(status: successful ? 200 : 500, body: response_body, headers: {})
  end

  def stub_openaire
    url = ExternalApis::OpenAireService.api_base_url
    url = "#{url}#{ExternalApis::OpenAireService.search_path}"
    url = url % ExternalApis::OpenAireService.default_funder
    stub_request(:get, url).to_return(status: 200, body: '', headers: {})
  end

  def stub_orcid(success: true)
    url = Rails.configuration.x.orcid_api_base_url
    url = url.gsub("%{id}", "[0-9\\-]*")
    if success
      stub_request(:post, /#{}\/.*/).to_return(status: 201, body: mocked_orcid_response, headers: {})
    else
      stub_request(:post, /#{}\/.*/).to_return(status: 403, body: mocked_orcid_response, headers: {})
    end
  end

  def mocked_ror_response
    body = { number_of_results: 10, time_taken: 10, items: [] }
    10.times.each do
      body[:items] << {
        id: Faker::Internet.url(host: 'ror.org'),
        name: Faker::Company.unique.name,
        links: [[Faker::Internet.url, nil].sample],
        country: { country_name: Faker::Books::Dune.planet },
        external_ids: {
          FundRef: { preferred: nil, all: [Faker::Number.number(digits: 6)] }
        }
      }
    end
    body.to_json
  end

  def mocked_orcid_response(success: true)

    if success
      Faker::Number.number(digits: 8).to_s
    else
      <<-XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <error xmlns="http://www.orcid.org/ns/error">
          <response-code>401</response-code>
          <developer-message>401 Unauthorized: The client application is not authorized for this ORCID record. Full validation error: Access token is for a different record</developer-message>
          <user-message>The client application is not authorized.</user-message>
          <error-code>9017</error-code>
          <more-info>https://members.orcid.org/api/resources/troubleshooting</more-info>
      </error>
      XML
    end
  end

  def mock_shib_login(user:, successful: true)
    url = "#{Faker::Internet.url(scheme: "https", path: "")}"
    Rails.configuration.x.shibboleth.login_url = url
    Rails.rou
    stub_request(:get, url)
      .to_return(
        status: successful ? 200 : 401,
        body: successful ? mock_omniauth_call("shibboleth", user).to_json : {},
        headers: {}
      )
  end

  class MockShibbolethIdentityProvider
    # GET /Shibboleth.sso/login
    def login
      redirect_to user_shibboleth_omniauth_callback, status: 200
    end
  end

end
