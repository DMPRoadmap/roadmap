require "rails_helper"

RSpec.describe "Templates", type: :feature do

  before do
    @org      = create(:org)
    @template = create(:template, org: @org, phases: 2)
    @phase    = @template.phases.first
    @template.phases.each { |phase| create_list(:section, 2, phase: phase) }
    @user     = create(:user, org: @org)
    @user.perms << create(:perm, :modify_templates)
    sign_in(@user)
  end

  scenario "Org admin edits a template", :js do
    # Action
    click_link "Admin"
    click_link "Templates"

    # Expectations
    expect(current_path).to eql(organisational_org_admin_templates_path)

    # Action
    click_button "Actions"
    click_link "Edit"

    # Expectations
    expect(current_path).to eql(edit_org_admin_template_path(@template))

    # Action
    within "#phase_#{@phase.id}" do
      click_link "Edit phase"
    end

    # Expectations
    path = edit_org_admin_template_phase_path(@template, @template.phases.first)
    expect(current_path).to eql(path)

    # Action
    # Open the panel for a new Section
    find("a[href='#new_section']").click

    within "#collapseSectionNew" do
      fill_in :new_section_section_title, with: "My new section"
      tinymce_fill_in :new_section_section_description,
                      with: "This is the description of my new section"
      click_button "Save"
    end

    # Expectations
    last_section = Section.last
    expect(@template.sections.count).to eql(5)
    expect(last_section.title).to eql("My new section")
    expect(last_section.description).to match("This is the description of my new section")
    expect(last_section.description).to match("<p>")
  end

end
