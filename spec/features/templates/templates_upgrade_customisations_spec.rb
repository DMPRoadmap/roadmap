require "rails_helper"

RSpec.feature "Templates::UpgradeCustomisations", type: :feature do

  let(:funder) { create(:org, :funder, name: "The funder org") }

  let(:org) { create(:org, :organisation, name: "The User's org") }

  let(:user) { create(:user, org: org) }

  let(:original_template) {
    create(:template, :default, :publicly_visible, :published,
           org: funder, title: "Funder Template")
  }

  let(:template) { original_template.customize!(org) }

  before do
    create(:template, :default, :published, org: funder, title: "Default Template")
    create_list(:phase, 1, template: original_template).each do |phase|
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
    sign_in user
    visit org_admin_templates_path

    # Customise a Template that belongs to another funder Org
    click_link("Customisable Templates")

    within "#template_2" do
      click_button "Actions"
      click_link "Customise"
    end


    click_link "View all templates"

    # Publish our customisation
    within "#template_2" do
      click_button "Actions"
      click_link "Publish"
    end

    # Move to the other funder Org's Templates
    fill_in(:superadmin_user_org_name, with: funder.name)
    choose_suggestion(funder.name)
    click_button("Change affiliation")

    # Edit the original Template
    click_link "#{funder.name} Templates"

    within "#template_2" do
      click_button "Actions"
      click_link "Edit"
    end

    click_link(original_template.phases.first.title)

    click_link "Add a new section"
    within('#new_section_new_section') do
      fill_in :new_section_section_title, with: "New section title"
      tinymce_fill_in :new_section_section_description, with: "New section title"
      click_button("Save")
    end
    latest_original_template = Template.last
    expect(latest_original_template.reload.sections).to have(3).items
    click_link "View all templates"

    within "#template_4" do
      click_button "Actions"
      click_link "Publish changes"
    end

    # Go back to the original Org...

    fill_in(:superadmin_user_org_name, with: org.name)
    choose_suggestion(org.name)
    click_button("Change affiliation")

    click_link "Customisable Templates"

    within "#template_4" do
      click_button "Actions"
      click_link "Transfer customisation"
    end
    expect(page).to have_text("Customisations are published")
    latest_template = Template.last
    expect(latest_template.reload.sections).to have(3).items
    expect(latest_original_template.reload.sections).to have(3).items
    expect(original_template.sections).to have(2).items
    expect(template.sections).to have(2).items
  end

end
