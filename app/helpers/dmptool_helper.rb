# frozen_string_literal: true

require 'httparty'
require 'rss'

# DMPTool specific helpers
module DmptoolHelper
  # Pagination link to view all results (currently only used on the public plans page)
  def current_page_query_params
    uri = URI.parse(request.fullpath)
    query_params = uri.query.present? ? CGI.parse(uri.query) : {}
    query_params.transform_values { |val| val.is_a?(Array) ? val.first : val }
  end

  # Generate a hyperlink for the DMP ID
  def dmp_id_for_display(dmp_id:, without_prefix: true)
    return _('None defined') if dmp_id.blank?

    without = dmp_id.gsub(/https?:\/\//, '').gsub('doi.org/', '')
    label = without_prefix ? without : dmp_id
    return link_to label, dmp_id, class: 'has-new-window-popup-info' if Rails.env.production?

    url = DmpIdService.landing_page_url
    return dmp_id unless url.present? && without != dmp_id && !without.starts_with?('http')

    link_to(label, "#{url}#{without}", class: 'has-new-window-popup-info')
  end

  # Converts some of the language of User validation errors
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def auth_has_error?(attribute)
    return false unless attribute.present? && resource.present? &&
                        resource.errors.present? && resource.errors.any?

    errs = resource.errors.full_messages

    case attribute.to_sym
    when :org, :org_id
      errs.any? { |err| err.start_with?('Institution') }
    when :accept_terms
      errs.any? { |err| err.include?('the terms') }
    else
      errs.any? { |err| err.start_with?(attribute.to_s.humanize) }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # Determine which UI template we should use based on the page
  def page_body_template
    template = 't-generic'
    template = 't-publicplans' if active_page?(public_plans_path, false)
    template = 't-home' if active_page?(root_path, true) ||
                           active_page?(new_user_session_path, false) ||
                           active_page?(new_user_registration_path, true) ||
                           active_page?(user_registration_path, true) ||
                           active_page?(new_user_password_path, true)
    template
  end

  # Collect general statistics about the application
  def statistics
    cached = Rails.cache.read('stats')
    return cached unless cached.nil?

    stats = {
      user_count: User.select(:id).count,
      completed_plan_count: Plan.select(:id).count,
      institution_count: Org.participating.select(:id).count
    }
    cache_content('stats', stats)
    stats
  end

  # Get the last 5 blog posts
  def feed
    cached = Rails.cache.read('rss')
    return cached unless cached.nil?

    resp = HTTParty.get(Rails.configuration.x.application.blog_rss)
    return [] unless resp.code == 200

    rss = RSS::Parser.parse(resp.body, false).items.first(5)
    cache_content('rss', rss)
    rss
  rescue StandardError => e
    # If we were unable to connect to the blog rss
    logger.error("Caught exception RSS parse: #{e}.")
    []
  end

  # Store information in the cache
  def cache_content(type, data)
    return nil if type.blank?

    Rails.cache.write(type, data, expires_in: 60.minutes)
  rescue StandardError => e
    logger.error("Unable to add #{type} to the Rails cache: #{e}.")
  end

  def select_override_options(add_to_mine: true)
    opts = [
      ['Use defaults', '0'],
      ['Use mine', '1']
    ]
    opts.append(['Add mine to defaults', '2']) if add_to_mine
    opts
  end
end
