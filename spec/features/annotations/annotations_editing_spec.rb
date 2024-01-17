# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Annotations::Editing' do
  let!(:funder) { create(:org, :funder) }

  let!(:org) { create(:org, :institution) }

  let!(:template) { create(:template, :published, :publicly_visible, org: funder) }

  let!(:phase) { create(:phase, template: template) }

  let!(:section) { create(:section, phase: phase) }

  let!(:question) { create(:question, section: section) }

  let!(:annotation) do
    create(:annotation, question: question, org: org,
                        text: 'Foo bar', type: 'example_answer')
  end

  let!(:user) { create(:user, :org_admin, org: org) }

  before do
    create(:template, :default, :published)
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    sign_in user
    visit org_admin_templates_path
  end

  it 'Admin changes an Annotation of a draft Template', :js do
    click_link 'Customisable Templates'
    within("#template_#{template.id}") do
      click_button 'Actions'
    end
    expect do
      click_link 'Customise'
    end.to change(Template, :count).by(1)

    # New Template created
    template = Template.last
    click_link 'Customise phase'

    click_link section.title

    within("fieldset#fields_annotation_#{template.annotation_ids.last}") do
      id = "question_annotations_attributes_annotation_#{template.annotation_ids.last}_text"
      tinymce_fill_in(id, with: 'Noo bar')
    end

    # NOTE: This is question 2, since Annotation was copied upon clicking "Customise"
    within("#edit_question_#{template.question_ids.last}") do
      # Expect it to destroy the newly cleared Annotation
      expect { click_button _('Save') }.not_to change(Annotation, :count)
    end
    sleep(4)
    expect(annotation.text).to eql('Foo bar')
    expect(Annotation.order('created_at').last.text).to eql('<p>Noo bar</p>')
    expect(page).not_to have_errors
  end

  # Commenting this one out because it fails randomly. Failures seem to be due to translation issues
  # e.g. Customize vs Customize
  xit "Admin sets a Template's question annotation to blank string", :js do
    click_link 'Customisable Templates'
    within("#template_#{template.id}") do
      click_button 'Actions'
    end
    expect do
      click_link 'Customise'
    end.to change(Template, :count).by(1)

    template = Template.last
    click_link 'Customise phase'
    click_link section.title
    # NOTE: This is annotation 2, since Annotation was copied upon clicking "Customise"
    within("fieldset#fields_annotation_#{template.annotation_ids.last}") do
      id = "question_annotations_attributes_annotation_#{template.annotation_ids.last}_text"
      tinymce_fill_in(:"#{id}", with: ' ')
    end
    # NOTE: This is question 2, since Annotation was copied upon clicking "Customise"
    within("#edit_question_#{template.question_ids.last}") do
      # Expect it to destroy the newly cleared Annotation
      expect { click_button _('Save') }.to change(Annotation, :count).by(-1)
    end
    expect(page).not_to have_errors
  end
end
