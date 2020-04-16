# frozen_string_literal: true

require "rails_helper"

describe "contact_us/contacts/new.html.erb" do

  it "renders correctly" do
    url = Faker::Internet.url
    app_name = Faker::Company.name
    Rails.configuration.branding[:organisation][:url] = url
    Rails.configuration.branding[:application][:name] = app_name
    controller.prepend_view_path "app/views/branded"
    assign :contact, ContactUs::Contact.new
    render
    expect(rendered.include?("Contact Us")).to eql(true)
    expect(rendered.include?("You can find out more about us")).to eql(true)
    expect(rendered.include?("#{url}")).to eql(true)
    expect(rendered.include?("#{app_name}")).to eql(true)
    expect(response).to render_template(partial: "contact_us/contacts/_new_left")
    expect(response).to render_template(partial: "contact_us/contacts/_new_right")
  end

end
