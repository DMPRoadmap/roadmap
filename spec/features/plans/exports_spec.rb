# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PlansExports", type: :feature, js: true do

  let!(:template) { create(:template, phases: 2) }
  let!(:org) { create(:org, managed: true, is_other: false) }
  let!(:user) { create(:user, org: org) }
  let!(:plan) { create(:plan, template: template) }

  before do
    template.phases.each { |p| create_list(:section, 2, phase: p) }
    template.sections.each { |s| create_list(:question, 2, section: s) }
    plan.roles << create(:role, :commenter, user: user)
    plan.roles << create(:role, :creator, user: user)
    sign_in(user)
  end

  scenario "User downloads plan from organisational plans portion of the dashboard" do
    new_plan  = create(:plan, :publicly_visible, template: template)
    new_phase = create(:phase, template: template, sections: 2)
    new_phase.sections do |sect|
      create_list(:question, 2, section: sect)
    end
    new_plan.questions.each do |question|
      create(:answer, question: question, plan: new_plan)
    end
    new_plan.update(complete: true)
    new_user = create(:user, org: org)
    create(:role, :creator, :commenter, :administrator, :editor,
           plan: new_plan,
           user: new_user)
    sign_in(user)
    find(:css, "a[href*=\"/#{new_plan.id}/export.pdf\"]", visible: false).click
  end

  scenario "User downloads public plan belonging to other User" do
    new_plan = create(:plan, :publicly_visible, template: template)
    create(:role, :creator, plan: new_plan)
    sign_in(user)
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("html")
    new_window = window_opened_by { click_button "Download Plan" }
    within_window new_window do
      expect(page.source).to have_text(plan.title)
    end
  end

  scenario "User downloads org plan belonging to User in same org" do
    new_plan = create(:plan, :organisationally_visible, template: template)
    create(:role, :creator, plan: new_plan, user: create(:user, org: org))
    sign_in(user)
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("html")
    new_window = window_opened_by { click_button "Download Plan" }
    within_window new_window do
      expect(page.source).to have_text(plan.title)
    end
  end

  scenario "User downloads org plan belonging to User in other org" do
    new_plan = create(:plan, :organisationally_visible, template: template)
    create(:role, :creator, plan: new_plan)
    sign_in(create(:user))
    expect(page).not_to have_text(new_plan.title)
  end

  scenario "User attempts to download private plan belonging to User in same" do
    new_plan = create(:plan, :privately_visible, template: template)
    create(:role, :creator, plan: new_plan)
    sign_in(create(:user))
    expect(page).not_to have_text(new_plan.title)
  end

  scenario "User downloads their plan as HTML" do
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("html")
    new_window = window_opened_by { click_button "Download Plan" }
    within_window new_window do
      expect(page.source).to have_text(plan.title)
    end
  end

  scenario "User downloads their plan as PDF" do
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("pdf")
    click_button "Download Plan"
    expect(page.source).to have_text(plan.title)
  end

  scenario "User downloads their plan as CSV" do
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("csv")
    click_button "Download Plan"
    expect(page.source).to have_text(plan.title)
  end

  scenario "User downloads their plan as text" do
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("text")
    click_button "Download Plan"
    expect(page.source).to have_text(plan.title)
  end

  scenario "User downloads their plan as docx" do
    within("#plan_#{plan.id}") do
      click_button("Actions")
      click_link "Download"
    end
    select("docx")
    click_button "Download Plan"
    expect(page.source).to have_text(plan.title)
  end
end
