# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Templates::Editing', type: :feature do
  let!(:default_template) { create(:template, :default, :published) }

  let!(:funder) { create(:org, :funder) }

  let!(:org) { create(:org, :school, :organisation) }

  let!(:template) { create(:template, :published, :publicly_visible, org: funder) }

  let!(:user) { create(:user, org: org) }

  before do
    @phase = create(:phase, template: template)
    create_list(:section, 1, phase: @phase).each do |section|
      create_list(:question, 1, section: section)
    end
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    sign_in user
    visit org_admin_templates_path
  end

  scenario "Admin edits a Template's existing question", :js do
    click_link 'Customisable Templates'
    within("#template_#{template.id}") do
      click_button 'Actions'
    end
    click_link 'Customise'
    # New template created
    template = Template.last
    within("#phase_#{template.phase_ids.first}") do
      click_link 'Customise phase'
    end
    click_link template.sections.first.title
    within("#edit_question_#{template.question_ids.first}") do
      # rubocop:disable Lint/UselessAssignment, Style/PerlBackrefs
      textarea_id = page.body.match(/question_annotations_attributes_annotation_(\d+)_text/)
      tinymce_fill_in(:"question_annotations_attributes_annotation_#{$1}_text", with: 'Foo bar')
      # rubocop:enable Lint/UselessAssignment, Style/PerlBackrefs
      click_button 'Save'
    end
    # Make sure annotation has been updated
    expect(Question.find(template.question_ids.first).annotations.first.text).to eql('<p>Foo bar</p>')
    # Make sure blank records are not created for empty annotation form
    expect(Question.find(template.question_ids.first).annotations.count).to eql(1)
    expect(page).not_to have_errors
  end
end
