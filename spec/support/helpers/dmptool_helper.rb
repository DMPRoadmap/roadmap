# frozen_string_literal: true

# Set basic config settings
Rails.configuration.x.application.admin_emails = 'admin@example.com'
Rails.configuration.x.application.api_documentation_overview_url = 'http://localhost:3000/docs'
Rails.configuration.x.application.api_max_page_size = 20
Rails.configuration.x.application.archived_accounts_email_suffix = 'test'
Rails.configuration.x.application.blog_rss = 'https://blog.example.org/feed/'
Rails.configuration.x.application.csv_separators = ','
Rails.configuration.x.application.name = 'Test App'
Rails.configuration.x.application.restrict_orgs = false

Rails.configuration.x.cache.org_selection_expiration = 1.day
Rails.configuration.x.cache.research_projects_expiration = 1.day

Rails.configuration.x.madmp.enable_citation_lookup = false
Rails.configuration.x.madmp.enable_dmp_id_registration = false
Rails.configuration.x.madmp.enable_orcid_publication = false
Rails.configuration.x.madmp.extract_data_quality_statements_from_themed_questions = false
Rails.configuration.x.madmp.extract_preservation_statements_from_themed_questions = false
Rails.configuration.x.madmp.extract_security_privacy_statements_from_themed_questions = false

Rails.configuration.x.organisation.abbreviation = 'TEST'
Rails.configuration.x.organisation.do_not_reply_email = 'do-not-reply@example.com'
Rails.configuration.x.organisation.helpdesk_email = 'help@example.com'
Rails.configuration.x.organisation.email = 'org@example.com'

Rails.configuration.x.plans.default_percentage_answered = 50
Rails.configuration.x.plans.default_visibility = 1
Rails.configuration.x.plans.org_admins_read_all = true
Rails.configuration.x.plans.super_admins_read_all = true

Rails.configuration.x.recaptcha.enabled = false
Rails.configuration.x.results_per_page = 20

Rails.configuration.x.shibboleth&.enabled = true
Rails.configuration.x.shibboleth.use_filtered_discovery_service = true

module Helpers
  module DmptoolHelper
    def mock_devise_env_for_controllers
      # Controller Tests don't have access to the `request` so we need to stub it and the
      # Devise mappings
      expect(@controller.is_a?(ApplicationController)).to eql(true),
                                                          'Cannot mock devise env before defining @controller!'
      devise_mappings = OpenStruct.new('devise.mapping': Devise.mappings[:user])
      @controller.stubs(:request).returns(OpenStruct.new(env: devise_mappings))
    end

    def shibbolize_org(org:)
      return nil if org.blank?

      Rails.configuration.x.shibboleth.enabled = true
      Rails.configuration.x.shibboleth.use_filtered_discovery_service = true
      create_shibboleth_entity_id(org: org)
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
      stub_request(:get, 'https://example.org/feed').to_return(
        status: 200, body: xml.to_s, headers: {}
      )
      stub_request(:get, 'https://blog.example.org/feed/').to_return(
        status: 200, body: xml.to_s, headers: {}
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
