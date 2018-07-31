require "rails_helper"

RSpec.describe "Plans", type: :feature do

  before do
    @default_template = create(:template, :default, :published)
    @phase = create(:phase, template: @default_template)
    # Create a couple of Sections
    @section1 = create(:section, phase: @phase)
    @section2 = create(:section, phase: @phase)

    # Create one of each type of Question
    @textarea_question = create(:question, :textarea, section: @section1)
    @textfield_question = create(:question, :textfield, section: @section1)

    @radiobutton_question = create(:question, :radiobuttons,
                                   section: @section1, options: 2)
    @checkbox_question = create(:question, :checkbox,
                                section: @section1, options: 2)
    @dropdown_question = create(:question, :dropdown,
                                 section: @section1, options: 4)
    @multiselectbox_question = create(:question, :multiselectbox,
                                      section: @section2, options: 4)
    @date_question = create(:question, :date, section: @section2)
    @rda_metadata_question   = create(:question, :rda_metadata,
                                      section: @section2)

    @org          = create(:org)
    @research_org = create(:org, :organisation, :research_institute,
                           templates: 1)
    @funding_org  = create(:org, :funder, templates: 1)
    @template     = create(:template, org: @org)
    @user         = create(:user, org: @org)
    sign_in(@user)
  end

  scenario "User creates a new Plan", :js do
    # Action
    click_link "Create plan"
    fill_in :plan_title, with: "My test plan"
    fill_in :plan_org_name, with: @research_org.name

    find('#suggestion-2-0').click
    fill_in :plan_funder_name, with: @funding_org.name
    find('#suggestion-3-0').click
    click_button "Create plan"

    # Expectations
    expect(@user.plans).to be_one
    @plan = Plan.last
    expect(current_path).to eql(plan_path(@plan))

    ##
    # User updates plan content...

    # Action
    expect(page).to have_css("input[type=text][value='#{@plan.title}']")

    within "#edit_plan_#{@plan.id}" do
      fill_in "Grant number", with: "1234"
      fill_in "Project abstract", with: "Plan abstract..."
      fill_in "ID", with: "ABCDEF"
      fill_in "ORCID iD", with: "My ORCID"
      fill_in "Phone", with: "07787 000 0000"
      click_button "Submit"
    end

    # Reload the plan to get the latest from memory
    @plan.reload

    expect(current_path).to eql(overview_plan_path(@plan))
    expect(@plan.title).to eql("My test plan")
    expect(@plan.funder_name).to eql(@funding_org.name)
    expect(@plan.grant_number).to eql("1234")
    expect(@plan.description).to eql("Plan abstract...")
    expect(@plan.identifier).to eql("ABCDEF")
    name = [@user.firstname, @user.surname].join(" ")
    expect(@plan.principal_investigator).to eql(name)
    expect(@plan.principal_investigator_identifier).to eql("My ORCID")
    expect(@plan.principal_investigator_email).to eql(@user.email)
    expect(@plan.principal_investigator_phone).to eql("07787 000 0000")
  end

  scenario "User fills out their Plan", :js do
    # Setup
    @plan = create(:plan, template: @default_template)
    create(:role, :creator, :editor, :commenter, user: @user, plan: @plan)
    sign_in(@user)
    visit overview_plan_path(@plan)
    question_count = @default_template.questions.count

    # Action
    click_link "Write plan"

    # Expectations
    expect(current_path).to eql(edit_plan_path(@plan))
    # 4 sections x 3 questions
    expect(page).to have_text("0/#{question_count} answered")

    # Action
    find("#section-panel-1").click
    # Fill in the answer form...
    within("#answer-form-#{@textarea_question.id}") do
      tinymce_fill_in "answer-text-#{@textarea_question.id}", "My test answer"
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "1/#{question_count} answered"
    expect(Answer.where(question_id: @textarea_question.id)).to be_any

    # Fill in the answer form...
    within("#answer-form-#{@textfield_question.id}") do
      fill_in :answer_text, with: "My test answer"
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "2/#{question_count} answered"
    expect(Answer.where(question_id: @textfield_question.id)).to be_any

    # Fill in the answer form...
    within("#answer-form-#{@radiobutton_question.id}") do
      choose @radiobutton_question.question_options.first.text
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "3/#{question_count} answered"
    expect(Answer.where(question_id: @radiobutton_question.id)).to be_any

    # Fill in the answer form...
    within("#answer-form-#{@checkbox_question.id}") do
      check @checkbox_question.question_options.first.text
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "4/#{question_count} answered"
    expect(Answer.where(question_id: @checkbox_question.id)).to be_any

    # Fill in the answer form...
    within("#answer-form-#{@dropdown_question.id}") do
      select @dropdown_question.question_options.first.text
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "5/#{question_count} answered"
    expect(Answer.where(question_id: @dropdown_question.id)).to be_any

    ##
    # Section 2
    find("#section-panel-1").click
    save_and_open_screenshot
    find("#section-panel-2").click
    save_and_open_screenshot

    # Fill in the answer form...
    within("#answer-form-#{@multiselectbox_question.id}") do
      select @multiselectbox_question.question_options.first.text
      click_button "Save"
    end

    # Expectations
    expect(page).to have_text "Answered just now"
    expect(page).to have_text "6/#{question_count} answered"
    expect(Answer.where(question_id: @multiselectbox_question.id)).to be_any

    # TODO: Find out how Date fields should work and test them...
    # within("#answer-form-#{@date_question.id}") do
    #   fill_in :answer_text, with: Date.today.to_s
    #   click_button "Save"
    # end
    #
    # # Expectations
    # expect(page).to have_text "Answered just now"
    # expect(page).to have_text "7/#{question_count} answered"
    # expect(Answer.where(question_id: @date_question.id)).to be_any
  end

end
