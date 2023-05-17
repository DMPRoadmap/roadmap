# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PlansExports', js: true do
  let!(:template) { create(:template, phases: 2) }
  let!(:org) { create(:org, managed: true, is_other: false) }
  let!(:user) { create(:user, org: org) }
  let!(:plan) { create(:plan, template: template) }

  before do
    template.phases.each { |p| create_list(:section, 2, phase: p) }
    template.sections.each { |s| create_list(:question, 2, section: s) }
    plan.roles << create(:role, :commenter, user: user)
    plan.roles << create(:role, :creator, user: user)
    sign_in user
    visit root_path
  end

  it 'User downloads plan from organisational plans portion of the dashboard' do
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
    sign_in user
    visit root_path
    find(:css, "a[href*=\"/#{new_plan.id}/export.pdf\"]", visible: false).click
  end

  it 'User downloads public plan belonging to other User' do
    new_plan = create(:plan, :publicly_visible, template: template)
    create(:role, :creator, plan: new_plan)
    sign_in user
    visit root_path
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('html')
    new_window = window_opened_by { click_button 'Download Plan' }
    within_window new_window do
      expect(page.source).to have_text(plan.title)
    end
  end

  it 'User downloads org plan belonging to User in same org' do
    new_plan = create(:plan, :organisationally_visible, template: template)
    create(:role, :creator, plan: new_plan, user: create(:user, org: org))
    sign_in user
    visit root_path
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('html')
    new_window = window_opened_by { click_button 'Download Plan' }
    within_window new_window do
      expect(page.source).to have_text(plan.title)
    end
  end

  it 'User downloads org plan belonging to User in other org' do
    new_plan = create(:plan, :organisationally_visible, template: template)
    create(:role, :creator, plan: new_plan)
    sign_in create(:user)
    visit root_path
    expect(page).not_to have_text(new_plan.title)
  end

  it 'User attempts to download private plan belonging to User in same' do
    new_plan = create(:plan, :privately_visible, template: template)
    create(:role, :creator, plan: new_plan)
    sign_in create(:user)
    visit root_path
    expect(page).not_to have_text(new_plan.title)
  end

  # Separate code to test all-phase-download for html since it requires operation in new window
  scenario 'User downloads their plan as HTML' do
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('html')
    if plan.phases.present?
      new_window = window_opened_by do
        _select_option('phase_id', 'All')
        click_button 'Download Plan'
      end
      within_window new_window do
        expect(page.source).to have_text(plan.title)
      end
      new_window = window_opened_by do
        _select_option('phase_id', plan.phases[1].id)
        click_button 'Download Plan'
      end
      within_window new_window do
        expect(page.source).to have_text(plan.title)
        expect(page.source).to have_text(plan.phases[1].title)
        expect(page.source).not_to have_text(plan.phases[2].title) if plan.phases.length > 2
      end
    else
      _regular_download('html')
    end
  end

  it 'User downloads their plan as PDF' do
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('pdf')
    if plan.phases.present?
      _all_phase_download
      _single_phase_download
    else
      _regular_download('pdf')
    end
  end

  it 'User downloads their plan as CSV' do
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('csv')
    _regular_download('csv')
  end

  it 'User downloads their plan as text' do
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('text')
    if plan.phases.present?
      _all_phase_download
      _single_phase_download
    else
      _regular_download('text')
    end
  end

  it 'User downloads their plan as docx' do
    within("#plan_#{plan.id}") do
      click_button('Actions')
      click_link 'Download'
    end
    select('docx')
    if plan.phases.present?
      _all_phase_download
      _single_phase_download
    else
      _regular_download('docx')
    end
  end

  # ===========================
  # = Helper methods =
  # ===========================

  # rubocop:disable Metrics/AbcSize
  # disable Rubocup metrics check to confirm both plan title and phase title on downloaded file
  def _regular_download(format)
    if format == 'html'
      new_window = window_opened_by do
        click_button 'Download Plan'
      end
      within_window new_window do
        expect(page.source).to have_text(plan.title)
      end
    else
      click_button 'Download Plan'
      expect(page.source).to have_text(plan.title)
    end
  end

  def _all_phase_download
    _select_option('phase_id', 'All')
    click_button 'Download Plan'
    expect(page.source).to have_text(plan.title)
    plan.phases.each do |phase| # All phase titles should be included in output
      expect(page.source).to have_text(phase.title)
    end
  end

  def _single_phase_download
    _select_option('phase_id', plan.phases[1].id)
    click_button 'Download Plan'
    expect(page.source).to have_text(plan.title)
    expect(page.source).to have_text(plan.phases[1].title)
    expect(page.source).not_to have_text(plan.phases[2].title) if plan.phases.length > 2
  end

  # rubocop:enable Metrics/AbcSize
  def _select_option(select_id, option_value)
    find(:id, select_id).find("option[value='#{option_value}']").select_option
  end
end
