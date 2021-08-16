# frozen_string_literal: true

module DmphubMocks

  ERROR_RESPONSE = File.read(
    Rails.root.join("spec", "support", "mocks", "dmphub", "error.json")
  ).freeze

  SUCCESS_RESPONSE = File.read(
    Rails.root.join("spec", "support", "mocks", "dmphub", "success.json")
  ).freeze

  def stub_minting_success!
    stub_request(:post, "https://api.test.dmphub.org/dois")
      .to_return(status: 200, body: SUCCESS_RESPONSE, headers: {})
  end

  def stub_minting_error!
    stub_request(:post, "https://api.test.dmphub.org/dois")
      .to_return(status: 400, body: ERROR_RESPONSE, headers: {})
  end

end
