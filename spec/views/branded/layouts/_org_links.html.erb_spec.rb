# frozen_string_literal: true

require "rails_helper"

describe "layouts/_org_links.html.erb" do

  before(:each) do
    controller.prepend_view_path "app/views/branded"
  end

  it "displays nothing if user is not logged in" do
    render
    expect(rendered).to eql("")
  end

  it "correctly displays the Org links" do
    links = [{ text: Faker::Lorem.word, link: Faker::Internet.url }]
    org = create(:org, links: { org: links })
    sign_in create(:user, org: org)
    render
    expect(rendered.include?(links.first[:text])).to eql(true)
    expect(rendered.include?(links.first[:link])).to eql(true)
  end

  it "correctly displays the Org contact email" do
    org = create(:org, contact_email: Faker::Internet.email)
    sign_in create(:user, org: org)
    render
    expect(rendered.include?("mailto:#{org.contact_email}")).to eql(true)
    expect(rendered.include?(org.contact_name)).to eql(true)
  end

end
