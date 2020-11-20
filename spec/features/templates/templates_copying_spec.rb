# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Templates::Copying", type: :feature do

  let!(:org) { create(:org, :funder, :organisation) }

  let!(:parent_template) do
    create(:template, :published, org: org)
  end

  let!(:user) { create(:user, org: org) }

  before do
    create_list(:phase, 2, template: parent_template).each do |phase|
      create_list(:section, 2, phase: phase).each do |section|
        create_list(:question, 2, section: section)
      end
    end
    user.perms << create(:perm, :modify_templates)
    user.perms << create(:perm, :add_organisations)
    sign_in user
    visit org_admin_templates_path
  end

  scenario "Admin copies an existing Template", :js do
    # Setup
    click_link org.name

    # Action
    within("#template_#{parent_template.id}") do
      click_button "Actions"
      click_link "Copy"
    end

    # Expectations
    expect(Template.count).to eql(2)
    new_template = Template.last
    expect(new_template.title).to include(parent_template.title)
    expect(new_template.phases).to have_exactly(2).items
    expect(new_template.sections).to have_exactly(4).items
    expect(new_template.questions).to have_exactly(8).items
  end

end
