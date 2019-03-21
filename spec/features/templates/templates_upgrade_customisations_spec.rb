require "rails_helper"

RSpec.feature "Templates::UpgradeCustomisations", type: :feature do

  let(:funder) { create(:org, :funder, name: "The funder org") }

  let(:org) { create(:org, :organisation, name: "The User's org") }

  let(:user) { create(:user, org: org) }

  let(:funder_template) do
    create(:template, :default, :publicly_visible, :published,
           org: funder, title: "Funder Template")
  end

  before do
    create_list(:phase, 1, template: funder_template).each do |phase|
      create_list(:section, 2, phase: phase).each do |section|
        create_list(:question, 2, section: section)
      end
    end
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    user.perms << create(:perm, :change_org_affiliation)
    user.perms << create(:perm, :add_organisations)
  end

  scenario "Admin upgrades customizations from funder Template", :js do
    # pending "Need S3 travis working to debug this test on Travis"
    sign_in user
    visit org_admin_templates_path

    # Customise a Template that belongs to another funder Org
    click_link("Customisable Templates")

    click_button "Actions"
    expect { click_link "Customise" }.to change { Template.count }.by(1)

    customized_template = Template.last

    # click_link "View all templates"
    visit customisable_org_admin_templates_path

    expect(page).to have_text('Unpublished')

    # Publish our customisation
    click_button "Actions"
    click_link "Publish"

    # Move to the other funder Org's Templates
    fill_in(:superadmin_user_org_name, with: funder.name)
    choose_suggestion(funder.name)
    click_button("Change affiliation")

    # Edit the original Template
    click_link "#{funder.name} Templates"

    expect(page).to have_text('Published')
    click_button "Actions"
    click_link "Edit"

    click_link(funder_template.phases.first.title)

    click_link "Add a new section"
    within('#new_section_new_section') do
      fill_in :new_section_section_title, with: "New section title"
      tinymce_fill_in :new_section_section_description, with: "New section title"
      expect { click_button("Save") }.to change { Section.count }.by(3)
    end
    new_funder_template = Template.last

    visit organisational_org_admin_templates_path

    click_button "Actions"
    click_link "Publish changes"
    expect(page).to have_text('Published')

    # Go back to the original Org...

    fill_in(:superadmin_user_org_name, with: org.name)
    choose_suggestion(org.name)
    click_button("Change affiliation")

    click_link "Customisable Templates"
    expect(page).to have_text('Original funder template has changed')

    click_button "Actions"
    click_link "Transfer customisation"

    new_customized_template = Template.last

    expect(page).to have_text("Customisations are published")

    expect(funder_template.sections).to have(2).items
    expect(customized_template.sections).to have(2).items
    expect(new_customized_template.sections).to have(3).items
    expect(new_funder_template.sections).to have(3).items
  end

end
