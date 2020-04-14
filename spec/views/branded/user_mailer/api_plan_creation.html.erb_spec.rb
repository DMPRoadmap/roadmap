# frozen_string_literal: true

require "rails_helper"

describe "user_mailer/api_plan_creation.html.erb" do

  it "renders the email" do
    controller.prepend_view_path "app/views/branded"
    plan = create(:plan)
    contributor = build(:contributor, plan: plan)
    assign :plan, plan
    assign :contributor, contributor
    render
    expect(rendered.include?(plan.id.to_s)).to eql(true)
    expect(rendered.include?(plan.title)).to eql(true)
    expect(rendered.include?(contributor.email)).to eql(true)
  end

end
