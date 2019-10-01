require "rails_helper"

RSpec.describe "Plans", type: :feature do

  before do
    @default_template = create(:template, :default, :published)
    @org          = create(:org)
    @research_org = create(:org, :organisation, :research_institute,
                           templates: 1)
    @funding_org  = create(:org, :funder, templates: 1)
    @template     = create(:template, org: @org)
    @user         = create(:user, org: @org)
    sign_in(@user)

    OpenURI.expects(:open_uri).returns(<<~XML
      <form-value-pairs>
        <value-pairs value-pairs-name="H2020projects" dc-term="relation">
          <pair>
            <displayed-value>
              115797 - INNODIA - Translational approaches to disease modifying therapy of type 1 diabetes: an innovative approach towards understanding and arresting type 1 diabetes – Sofia ref.: 115797
            </displayed-value>
            <stored-value>info:eu-repo/grantAgreement/EC/H2020/115797/EU</stored-value>
          </pair>
        </value-pairs>
      </form-value-pairs>
    XML
    )

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
      fill_in "Grant number", with: "Innodia"
      fill_in "Project abstract", with: "Plan abstract..."
      fill_in "ID", with: "ABCDEF"
      fill_in "ORCID iD", with: "My ORCID"
      fill_in "Phone", with: "07787 000 0000"
      click_button "Save"
    end

    # Reload the plan to get the latest from memory
    @plan.reload

    expect(current_path).to eql(overview_plan_path(@plan))
    expect(@plan.title).to eql("My test plan")
    expect(@plan.funder_name).to eql(@funding_org.name)
    expect(@plan.grant_number).to eql("115797")
    expect(@plan.description).to eql("Plan abstract...")
    expect(@plan.identifier).to eql("ABCDEF")
    name = [@user.firstname, @user.surname].join(" ")
    expect(@plan.principal_investigator).to eql(name)
    expect(@plan.principal_investigator_identifier).to eql("My ORCID")
    expect(@plan.principal_investigator_email).to eql(@user.email)
    expect(@plan.principal_investigator_phone).to eql("07787 000 0000")
  end

end
