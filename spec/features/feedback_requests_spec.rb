require "rails_helper"

RSpec.describe "FeedbackRequests", type: :feature do

  let!(:plan) { create(:plan, :organisationally_visible) }

  let!(:org) do
    create(:org, feedback_enabled: true,
                 feedback_email_subject: Faker::Lorem.sentence,
                 feedback_email_msg: Faker::Lorem.paragraph)
  end
  let!(:user) { create(:user, org: org) }

  before do
    plan.roles << create(:role, user: user, commenter: true)
    plan.roles << create(:role, user: user, creator: true)
    plan.roles << create(:role, user: user, editor: true)
    plan.roles << create(:role, user: user, administrator: true)
    sign_in(user)
  end

  scenario "User requests feedback for Plan", :js do
    # Actions
    click_link plan.title
    expect(current_path).to eql(plan_path(plan))
    click_link "Share"
    click_link "Request feedback"

    # Expectations
    expect(plan.reload).to be_feedback_requested
    expect(ActionMailer::Base.deliveries).to have_exactly(1).item
  end

end
