# frozen_string_literal: true

module DmptoolHelper
  def access_sign_in_options_modal
    click_link 'Sign in'
  end

  def access_sign_in_modal
    access_sign_in_options_modal
    click_on 'Email address'
  end

  def access_create_account_modal
    access_sign_in_options_modal
    click_on 'Create an account'
    # find("#show-create-account-form").first.click
  end

  def access_shib_ds_modal
    access_sign_in_options_modal
    click_on 'Your institution'
  end

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
    stub_request(:get, 'https://blog.dmptool.org/feed').to_return(
      status: 200, body: xml.to_s, headers: {}
    )
    stub_request(:get, 'https://blog.example.org/feed').to_return(
      status: 200, body: xml.to_s, headers: {}
    )
    stub_request(:get, 'https://example.org/feed').to_return(
      status: 200, body: xml.to_s, headers: {}
    )
    stub_request(:get, 'https://example.org/feed').to_return(
      status: 200, body: xml.to_s, headers: {}
    )
  end
end
