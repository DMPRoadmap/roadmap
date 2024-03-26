# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Questions::Radio button questions', type: :feature do
  before do
    @default_template  = create(:template, :default, :published)
    @phase             = create(:phase, template: @default_template)
    # Create a couple of Sections
    @section           = create(:section, phase: @phase)

    @question = create(:question, :radiobuttons, section: @section, options: 2)
    @user = create(:user)
    @plan = create(:plan, template: @default_template)
    create(:role, :creator, :editor, :commenter, user: @user, plan: @plan)
    sign_in(@user)
  end

  scenario 'User answers a radio button question', :js do
    # Setup
    visit overview_plan_path(@plan)

    # Action
    click_link 'Write plan'

    # Expectations
    expect(current_path).to eql(edit_plan_path(@plan))
    # 4 sections x 3 questions
    expect(page).to have_text('(0 / 1)')

    # Action
    find("#section-panel-#{@section.id}").click
    # Fill in the answer form...
    within("#answer-form-#{@question.id}") do
      choose @question.question_options.first.text
      click_button 'Save'
      sleep(0.2)
    end

    # Expectations
    expect(page).to have_text 'Answered just now'
    expect(page).to have_text '1/1 answered'
    expect(Answer.where(question_id: @question.id)).to be_any
  end
end
