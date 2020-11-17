# frozen_string_literal: true

require "rails_helper"

describe "contact_us/contacts/_new_right.html.erb" do

  it "renders the panel correctly" do
    controller.prepend_view_path "app/views/branded"
    # rubocop:disable Metrics/LineLength
    org = {
      name: Faker::Company.name,
      address_line1: Faker::Address.street_address,
      address_line2: Faker::Address.secondary_address,
      address_line3: Faker::Address.community,
      address_line4: "#{Faker::Address.city}, #{Faker::Address.state_abbr} #{Faker::Address.zip_code}",
      address_country: Faker::Address.country,
      google_maps_link: Faker::Internet.url
    }
    # rubocop:enable Metrics/LineLength
    Rails.configuration.x.organisation[:name] = org[:name]
    # rubocop:disable Naming/VariableNumber
    Rails.configuration.x.organisation[:address] = {
      line_1: org[:address_line1],
      line_2: org[:address_line2],
      line_3: org[:address_line3],
      line_4: org[:address_line4],
      country: org[:address_country]
    }
    # rubocop:enable Naming/VariableNumber
    render
    expect(rendered.include?("<strong>#{org[:name]}")).to eql(true)
    expect(rendered.include?("#{org[:address_line1]}<br>")).to eql(true)
    expect(rendered.include?("#{org[:address_line2]}<br>")).to eql(true)
    expect(rendered.include?("#{org[:address_line3]}<br>")).to eql(true)
    expect(rendered.include?("#{org[:address_line4]}<br>")).to eql(true)
    expect(rendered.include?("#{org[:address_country]}<br>")).to eql(true)
    expect(rendered.include?("<iframe")).to eql(true)
  end

end
