# frozen_string_literal: true

xml.instruct!

# rubocop:disable Metrics/BlockLength
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc public_templates_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc public_plans_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc public_orgs_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc about_us_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc contact_us_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc terms_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc privacy_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc help_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc quick_start_guide_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc faq_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc general_guidance_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc editorial_board_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
  xml.url do
    xml.loc promote_url
    xml.lastmod Time.utc(2022, 0o1, 19).strftime("%Y-%m-%d")
  end
end
# rubocop:enable Metrics/BlockLength
