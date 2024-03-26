# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Templates::UpgradeCustomisations', type: :feature do
  let(:funder) { create(:org, :funder, name: 'The funder org') }

  let(:org) { create(:org, :organisation, name: 'The User org') }

  let(:user) { create(:user, org: org) }

  let(:question_format) { create(:question_format, :textarea) }

  let(:funder_template) do
    create(:template, :default, :publicly_visible, :published,
           org: funder, title: 'Funder Template')
  end

  before do
    create_list(:phase, 1, template: funder_template).each do |phase|
      create_list(:section, 2, phase: phase).each do |section|
        create_list(:question, 2, :textarea, section: section)
      end
    end
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    user.perms << create(:perm, :change_org_affiliation)
  end

  scenario 'Admin upgrades customizations from funder Template', :js do
    # pending "Need S3 travis working to debug this test on Travis"
    sign_in user
    visit org_admin_templates_path

    # Customise a Template that belongs to another funder Org
    click_link('Customisable Templates')

    click_button 'Actions'
    expect { click_link 'Customise' }.to change { Template.count }.by(1)

    customized_template = Template.last

    # click_link "View all templates"
    visit customisable_org_admin_templates_path

    expect(page).to have_text('Unpublished')

    # Publish our customisation
    click_button 'Actions'
    click_link 'Publish'
    expect(customized_template.reload.published?).to eql(true)

    # Move to the other funder Org's Templates
    choose_suggestion('superadmin_user_org_name', funder)
    click_button('Change affiliation')

    # Edit the original Template
    click_link "#{funder.name} Templates"

    expect(page).to have_text('Published')
    click_button 'Actions'
    click_link 'Edit'

    click_link(funder_template.phases.first.title)

    click_link 'Add a new section'
    within('#new_section_new_section') do
      fill_in :new_section_section_title, with: 'Cool New section title'
      tinymce_fill_in :new_section_section_description, with: 'New section Description'
      expect { click_button('Save') }.to change { Section.count }.by(3)
    end

    within("#section-#{Section.last.id}") do
      within('.new-question-button') do
        click_link('Add Question')
      end

      expect(page).to have_selector('#new_question_new_question')
      within('#new_question_new_question') do
        tinymce_fill_in :new_question_question_text, with: 'Text for this specific question'
        expect { click_button('Save') }.to change { Question.count }.by(1)
      end
    end

    new_funder_template = Template.last

    visit organisational_org_admin_templates_path

    click_button 'Actions'
    click_link 'Publish changes'
    expect(new_funder_template.reload.published?).to eql(true)

    # Go back to the original Org...
    choose_suggestion('superadmin_user_org_name', org)
    click_button('Change affiliation')

    click_link 'Customisable Templates'

    expect(page).to have_text('Original funder template has changed')

    click_button 'Actions'
    click_link 'Transfer customisation'

    new_customized_template = Template.last

    expect(page).to have_text('Customisations are published')

    expect(funder_template.sections).to have(2).items
    expect(customized_template.sections).to have(2).items
    expect(new_customized_template.sections).to have(3).items
    expect(new_funder_template.sections).to have(3).items
  end
end
