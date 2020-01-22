# frozen_string_literal: true

module Webmocks

  def stub_ror_service
    url = ExternalApis::RorService.api_base_url
    headers = ExternalApis::RorService.headers

    # Mock the results of the ping/heartbeat check
    stub_request(:get, "#{url}#{ExternalApis::RorService.heartbeat_path}")
      .with(headers: headers).to_return(status: 200, body: "OK", headers: {})

    # Mock the results of a search. We are only returning the elements of the
    # ROR response that we actually care about here
    stub_request(:get, /#{url}#{ExternalApis::RorService.search_path}\.*/)
      .with(headers: headers)
      .to_return(status: 200, body: mocked_ror_response, headers: {})
  end

  def stub_openaire
    url = OpenAireRequest::API_URL.split("%s").first
    headers = {
      "Accept": "*/*",
      "Accept-Encoding": "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent": "Ruby"
    }
    stub_request(:get, /#{url}.*/)
      .with(headers: headers)
      .to_return(status: 200, body: "", headers: {})
  end

  # rubocop:disable Metrics/MethodLength
  def mocked_ror_response
    body = { number_of_results: 10, time_taken: 10, items: [] }
    10.times.each do
      body[:items] << {
        id: Faker::Internet.url(host: "ror.org"),
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
  # rubocop:enable Metrics/MethodLength

end
