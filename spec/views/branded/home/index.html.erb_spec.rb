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
    expect(rendered.include?("DMPTool by the Numbers")).to eql(true)
    expect(rendered.include?("<p>Users</p>")).to eql(true)
    expect(rendered.include?("<p>Plans</p>")).to eql(true)
    expect(rendered.include?("<p>Participating Institutions</p>")).to eql(true)
    expect(rendered.include?("Top Templates")).to eql(true)
    expect(rendered.include?("<li>#{top_five.first}</li>")).to eql(true)
    expect(rendered.include?("View the list of funder requirements")).to eql(true)
    expect(rendered.include?("DMPTool News")).to eql(true)
    expect(rendered.include?("News is currently unavailable")).to eql(true)
    expect(rendered.include?("Go to the blog")).to eql(true)
    expect(rendered.include?("RSS")).to eql(true)
  end

end
