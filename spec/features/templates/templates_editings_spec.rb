require 'rails_helper'

RSpec.feature "Templates::Editing", type: :feature do

  let!(:funder) { create(:org, :funder) }

  let!(:org) { create(:org, :school, :organisation) }

  let!(:template) { create(:template, :published, :publicly_visible, org: funder) }

  let!(:user) { create(:user, org: org) }

  before do
    create(:template, :default, :published)
    create_list(:phase, 1, template: template).each do |phase|
      create_list(:section, 1, phase: phase).each do |section|
        create_list(:question, 1, section: section)
      end
    end
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    sign_in user
    visit org_admin_templates_path
  end

  scenario "Admin edits a Template's existing question", :js do
    click_link "Customisable Templates"
    within("#template_#{template.id}") do
      click_button "Actions"
    end
    click_link "Customise"
    within("#phase_2") do
      click_link "Customise phase"
    end
    click_link template.sections.first.title
    within("#edit_question_2") do
      textarea_id = page.body.match(/question\_annotations\_attributes\_annotation\_(\d+)\_text/)
      tinymce_fill_in(:"question_annotations_attributes_annotation_#{$1}_text", with: "Foo bar")
      click_button 'Save'
    end
    # Make sure annotation has been updated
    expect(Question.find(2).annotations.first.text).to eql("Foo bar")
    # Make sure blank records are not created for empty annotation form
    expect(Question.find(2).annotations.count).to eql(1)
    expect(page).not_to have_errors
  end

end
