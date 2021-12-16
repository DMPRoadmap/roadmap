# frozen_string_literal: true

module DmptoolHelper
  include IdentifierHelper

  def mock_devise_env_for_controllers
    # Controller Tests don't have access to the `request` so we need to stub it and the
    # Devise mappings
    expect(@controller.is_a?(ApplicationController)).to eql(true), 'Cannot mock devise env before defining @controller!'
    devise_mappings = OpenStruct.new('devise.mapping': Devise.mappings[:user])
    @controller.stubs(:request).returns(OpenStruct.new(env: devise_mappings))
  end

  def shibbolize_org(org:)
    return nil unless org.present?

    Rails.configuration.x.shibboleth.enabled = true
    Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
    create_shibboleth_entity_id(org: @org)
  end

  # rubocop:disable Metrics/MethodLength
  def mock_blog
    xml = <<-XML
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>#{Faker::Lorem.sentence}</title>
        <item>
          <title>#{Faker::Lorem.sentence}</title>
        </item>
        <item>
          <title>#{Faker::Lorem.sentence}</title>
        </item>
      </channel>
    </rss>
    XML
    stub_request(:get, 'https://blog.dmptool.org/feed/').to_return(
      status: 200, body: xml.to_s, headers: {}
    )
    stub_request(:get, 'https://blog.example.org/feed/').to_return(
      status: 200, body: xml.to_s, headers: {}
    )
  end
  # rubocop:enable Metrics/MethodLength
end
