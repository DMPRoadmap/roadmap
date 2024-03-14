# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'FeedbackRequests', type: :feature do
  include Webmocks

  let!(:plan) { create(:plan, :organisationally_visible) }

  let!(:org) do
    create(:org, feedback_enabled: true,
                 feedback_msg: Faker::Lorem.paragraph)
  end
  let!(:user) { create(:user, org: org) }

  before do
    plan.roles << create(:role, :commenter, :creator, :editor, :administrator, user: user)
    sign_in(user)
    ActionMailer::Base.deliveries = []
    stub_openaire
  end

  after do
    ActionMailer::Base.deliveries = []
  end

  scenario 'User requests feedback for Plan', :js do
    # Actions
    click_link plan.title
    expect(current_path).to eql(plan_path(plan))

    # Click "Request feedback" tab
    within('ul.nav.nav-tabs') do
      click_link 'Request feedback'
    end

    # Click "Request feedback" button within panel
    within('.tab-pane.active') do
      click_link 'Request feedback'
    end

    # Expectations
    expect(plan.reload).to be_feedback_requested
    expect(ActionMailer::Base.deliveries).to have_exactly(1).item
  end
end
