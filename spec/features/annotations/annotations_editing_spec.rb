# frozen_string_literal: true

require 'rails_helper'
require 'timeout'

RSpec.feature 'Annotations::Editing', type: :feature do
  let!(:funder) { create(:org, :funder) }

  let!(:org) { create(:org, :school, :organisation) }

  let!(:template) { create(:template, :published, :publicly_visible, org: funder) }

  let!(:phase) { create(:phase, template: template) }

  let!(:section) { create(:section, phase: phase) }

  let!(:question) { create(:question, section: section) }

  let!(:annotation) do
    create(:annotation, question: question, org: org,
                        text: 'Foo bar', type: 'example_answer')
  end

  let!(:user) { create(:user, org: org) }

  before do
    create(:template, :default, :published)
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    sign_in user
    visit org_admin_templates_path
  end

  scenario 'Admin changes an Annotation of a draft Template', :js do
    click_link 'Customisable Templates'
    within("#template_#{template.id}") do
      click_button 'Actions'
    end
    template_count = Template.count
    click_link 'Customise'
    expect(page).to have_current_path(%r{\A/org_admin/templates/\d+\z})
    expect(Template.count).to eq(template_count + 1)

    # New Template created
    template = Template.last
    click_link 'Customise phase'

    click_link section.title

    copied_annotation_id = template.annotation_ids.last
    within("fieldset#fields_annotation_#{copied_annotation_id}") do
      id = "question_annotations_attributes_annotation_#{copied_annotation_id}_text"
      tinymce_fill_in(id, with: 'Noo bar')
    end

    # NOTE: This is question 2, since Annotation was copied upon clicking "Customise"
    annotation_count = Annotation.count
    question_id = template.question_ids.last
    within("#edit_question_#{question_id}") { click_button 'Save' }
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 until Annotation.uncached { Annotation.find(copied_annotation_id).text == '<p>Noo bar</p>' }
    end
    expect(Annotation.uncached { Annotation.count }).to eq(annotation_count)
    expect(annotation.text).to eql('Foo bar')
    expect(Annotation.uncached { Annotation.find(copied_annotation_id).text }).to eql('<p>Noo bar</p>')
    expect(page).not_to have_errors
  end

  scenario "Admin sets a Template's question annotation to blank string", :js do
    click_link 'Customisable Templates'
    within("#template_#{template.id}") do
      click_button 'Actions'
    end
    template_count = Template.count
    click_link 'Customise'
    expect(page).to have_current_path(%r{\A/org_admin/templates/\d+\z})
    expect(Template.count).to eq(template_count + 1)
    template = Template.last
    click_link 'Customise phase'
    click_link section.title
    # NOTE: This is annotation 2, since Annotation was copied upon clicking "Customise"
    copied_annotation_id = template.annotation_ids.last
    within("fieldset#fields_annotation_#{copied_annotation_id}") do
      id = "question_annotations_attributes_annotation_#{copied_annotation_id}_text"
      tinymce_fill_in(:"#{id}", with: ' ')
    end
    # NOTE: This is question 2, since Annotation was copied upon clicking "Customise"
    annotation_count = Annotation.count
    question_id = template.question_ids.last
    within("#edit_question_#{question_id}") { click_button 'Save' }
    Timeout.timeout(Capybara.default_max_wait_time) do
      sleep 0.05 while Annotation.uncached { Annotation.exists?(copied_annotation_id) }
    end
    expect(Annotation.uncached { Annotation.count }).to eq(annotation_count - 1)
    expect(page).not_to have_errors
  end
end
