# frozen_string_literal: true

require 'rails_helper'

describe 'plans/_share_form.html.erb' do
  before(:each) do
    @plan = create(:plan, :creator)
    @user = @plan.owner
    sign_in(@user)
    @plan_roles = @plan.roles.where(active: true)
  end

  it 'Renders set_visibility_info correctly according to default_percentage_answered value' do
    # Check what renders when default_percentage_answered is between 1 and 100
    Rails.configuration.x.plans.default_percentage_answered = rand(1..100)
    render partial: 'plans/share_form'
    expect(rendered.include?(format(_('Public or organisational visibility is intended for finished plans. ' \
                                      'You must answer at least %{percentage}%% of the questions to enable ' \
                                      'these options. Note: test plans are set to private visibility by default.'),
                                    percentage: Rails.configuration.x.plans.default_percentage_answered))).to eql(true)

    # Check what renders when default_percentage_answered is 0
    Rails.configuration.x.plans.default_percentage_answered = 0
    render partial: 'plans/share_form'
    expect(rendered.include?(_('Public or organisational visibility is intended for finished plans. ' \
                               'Note: test plans are set to private visibility by default.'))).to eql(true)
  end
end
