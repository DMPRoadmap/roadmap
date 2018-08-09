require "rails_helper"

RSpec.describe "Questions::RDA Metadata" do

  before do
    @default_template  = create(:template, :default, :published)
    @phase             = create(:phase, template: @default_template)
    # Create a couple of Sections
    @section           = create(:section, phase: @phase)

    @question = create(:question, :rda_metadata, section: @section)
    @user              = create(:user)
    @plan              = create(:plan, template: @default_template)
    create(:role, :creator, :editor, :commenter, user: @user, plan: @plan)
    sign_in(@user)
  end

  scenario "User answers a RDA Metadata question", :js do
    skip "Not sure how to test RDA Metadata fields?"

    # Setup
    visit overview_plan_path(@plan)

    # Action
    click_link "Write plan"

    # Expectations
    expect(current_path).to eql(edit_plan_path(@plan))
    # 4 sections x 3 questions
    expect(page).to have_text("0/1 answered")

    # Action
    find("#section-panel-1").click
    # Fill in the answer form...
    within("#answer-form-#{@question.id}") do
      fill_in :answer_text, with: Date.today.to_s
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "1/1 answered"
    expect(Answer.where(question_id: @question.id)).to be_any
  end

end
