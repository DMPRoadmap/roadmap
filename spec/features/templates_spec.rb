# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Templates' do
  before do
    @org      = create(:org)
    @template = create(:template, org: @org, phases: 2)
    @phase    = @template.phases.first
    @template.phases.each { |phase| create_list(:section, 2, phase: phase) }
    @user = create(:user, org: @org)
    @user.perms << create(:perm, :modify_templates)
    sign_in @user
    visit root_path
  end

  it 'Org admin edits a template', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    # Expectations
    expect(current_path).to eql(organisational_org_admin_templates_path)

    # Action
    click_button 'Actions'
    click_link 'Edit'

    # Expectations
    expect(current_path).to eql(edit_org_admin_template_path(@template))

    # Action
    within "#phase_#{@phase.id}" do
      click_link 'Edit phase'
    end

    # Expectations
    path = edit_org_admin_template_phase_path(@template, @template.phases.first)
    expect(current_path).to eql(path)

    # Action
    # Open the panel for a new Section
    find("a[href='#new_section']").click

    within '#collapseSectionNew' do
      fill_in :new_section_section_title, with: 'My new section'
      tinymce_fill_in :new_section_section_description,
                      with: 'This is the description of my new section'
      click_button 'Save'
    end

    # Expectations
    last_section = @template.phases.first.sections.order(:created_at).last
    expect(@template.sections.count).to be(5)
    expect(last_section.title).to eql('My new section')
    expect(last_section.description).to match('This is the description of my new section')
    expect(last_section.description).to match('<p>')
  end

end

RSpec.describe 'Org admin template preferences' do
  before do
    @PREF_SELECTORS = [
      '#customize_output_types_sel',
      '#template_customize_repositories',
      '#template_customize_metadata_standards',
      '#customize_licenses_sel',
      '#template_user_guidance_output_types',
      '#template_user_guidance_output_types_title',
      '#template_user_guidance_output_types_description',
      '#template_user_guidance_licenses',
    ]
    @PREF_MCE_SELECTORS = [
      '#template_user_guidance_repositories',
      '#template_user_guidance_metadata_standards',
    ]
 
    @org      = create(:org)
    @template = create(:template, published: true, org: @org, phases: 2)
    @phase    = @template.phases.first
    @template.phases.each { |phase| create_list(:section, 2, phase: phase) }
    @user = create(:user, org: @org)
    @user.perms << create(:perm, :modify_templates)
    sign_in @user
    visit root_path
  end

  it 'Navigate to preferences tab', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    click_button 'Actions'
    click_link 'Edit'

    click_link 'Preferences'
    expect(find('h1')).to have_content(_('Template Preferences'))
  end

  it 'Save Change to Preferences', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    click_button 'Actions'
    click_link 'Edit'

    click_link 'Preferences'
    find('#template_user_guidance_output_types').set('Hello')
    click_button 'Save Preferences'
  end

  describe 'save and version preferences', :js do
    before do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'
      find('#template_user_guidance_output_types').set('Hello')
      click_button 'Save Preferences'
    end

    it 'View Original Template Version - Ensure Read only page', :js do
      visit('/')
      click_button 'Admin'
      click_link 'Templates'
      click_button 'Actions'
      click_link 'History'
  
      within('table.table tbody') do
        click_link 'View'
      end
      click_link 'Preferences'
      expect(page).to have_selector('h1.treat-page-as-read-only')
      expect(find('h1')).to have_content(_('Template Preferences (VIEW)'))
      expect(find('form.edit_template')).not_to have_selector('button:enabled')
      expect(find('form.edit_template')).not_to have_selector('input:enabled')
      @PREF_SELECTORS.each do |s|
        expect(page).to have_selector("#{s}:disabled")
      end        
      @PREF_MCE_SELECTORS.each do |s|
        expect(page).to have_selector("#{s}:disabled")
      end        
    end
  
    it 'Edit Current Template Version', :js do
      visit('/')
      click_button 'Admin'
      click_link 'Templates'
      click_button 'Actions'
      click_link 'History'
  
      within('table.table tbody') do
        click_link 'Edit'
      end
      click_link 'Preferences'
      expect(page).not_to have_selector('h1.treat-page-as-read-only')
      expect(find('h1')).to have_content(_('Template Preferences'))
      expect(find('form.edit_template')).to have_selector('button:enabled')
      expect(find('form.edit_template')).to have_selector('input:enabled')
      @PREF_SELECTORS.each do |s|
        expect(page).to have_selector("#{s}:enabled")
      end        
      # tinymce hides the original selector
      @PREF_MCE_SELECTORS.each do |s|
        find(s, visible: false)
      end        
    end
  end

  it 'Enable research outputs', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    click_button 'Actions'
    click_link 'Edit'

    click_link 'Preferences'

    @PREF_SELECTORS.each do |s|
      expect(page).to have_selector(s)
    end
    # tinymce hides the original selector
    @PREF_MCE_SELECTORS.each do |s|
      find(s, visible: false)
    end        
    
    uncheck 'Enable research outputs tab?'
    @PREF_SELECTORS.each do |s|
      expect(page).not_to have_selector(s)
    end
    @PREF_MCE_SELECTORS.each do |s|
      expect(page).not_to have_selector(s)
    end        

    check 'Enable research outputs tab?'
    @PREF_SELECTORS.each do |s|
      expect(page).to have_selector(s)
    end
    # tinymce hides the original selector
    @PREF_MCE_SELECTORS.each do |s|
      find(s, visible: false)
    end        
  end

  it 'Output Types Selection', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    click_button 'Actions'
    click_link 'Edit'

    click_link 'Preferences'

    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output-types')
    expect(page).not_to have_selector('#my-output-types')

    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).not_to have_selector('#default-output-types')
    expect(page).to have_selector('#my-output-types')

    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output-types')
    expect(page).not_to have_selector('#my-output-types')

    find('#customize_output_types_sel').find('option[value="2"]').select_option
    expect(page).not_to have_selector('#default-output-types')
    expect(page).to have_selector('#my-output-types')

    OT = ResearchOutput.output_types.length
    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output-types li', count: OT)

    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).to have_selector('#my-output-types li', count: 0)

    find('#new_output_type').set('aaa')
    click_button _('Add an output type')
    expect(page).to have_selector('#my-output-types li', count: 1)

    find('#new_output_type').set('bbb')
    click_button _('Add an output type')
    expect(page).to have_selector('#my-output-types li', count: 2)

    # disallow duplicate value
    find('#new_output_type').set('aaa')
    click_button _('Add an output type')
    expect(page).to have_selector('#my-output-types li', count: 2)

    find('#customize_output_types_sel').find('option[value="2"]').select_option
    expect(page).to have_selector('#my-output-types li', count: OT + 2)

    # delete one standard selection
    find('#my-output-types li.standard a.output_type_remove', match: :first).click
    expect(page).to have_selector('#my-output-types li', count: OT + 2 - 1)

    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).to have_selector('#my-output-types li', count: 2)
  end
end
