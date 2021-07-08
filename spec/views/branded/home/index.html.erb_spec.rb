# frozen_string_literal: true

require "rails_helper"

describe "home/index.html.erb" do

  it "renders our version of the page" do
    stats = {
      user_count: Faker::Number.number,
      completed_plan_count: Faker::Number.number,
      institution_count: Faker::Number.number
    }
    top_five = [build(:template).title]
    controller.prepend_view_path "app/views/branded"
    assign :stats, stats
    assign :top_five, top_five
    render
    expect(rendered.include?("class=\"c-calltoaction\"")).to eql(true)
    expect(rendered.include?("class=\"c-login\"")).to eql(true)
    expect(rendered.include?("class=\"c-home-stats__users\"")).to eql(true)
    expect(rendered.include?("class=\"c-home-stats__participants\"")).to eql(true)
    expect(rendered.include?("class=\"c-home-stats__plans\"")).to eql(true)

    expect(response).to render_template(partial: "shared/authentication/_access_controls")
  end

end
