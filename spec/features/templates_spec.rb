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

  describe 'Repositories Selection' do
    before do
      info_json = {
        types: [''],
        subjects: [''],
        upload_types: []
      }.to_json

      Repository.new(
        name: 'Repo 1',
        description: 'Desc 1',
        uri: 'http://repo1.com',
        info: info_json
      ).save!

      Repository.new(
        name: 'Repo 2',
        description: 'Desc 2',
        uri: 'http://repo2.com',
        info: info_json
      ).save!

      Repository.new(
        name: 'Repo 3',
        description: 'Desc 3',
        uri: 'http://repo3.com',
        info: info_json
      ).save!
    end

    it 'Select 2 repositories and remove one', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      expect(page).not_to have_selector('button[data-target="#modal-search-repositories"]')
      expect(page).not_to have_selector('#modal-search-repositories-selections')

      find('#template_customize_repositories').check
      expect(page).to have_selector('button[data-target="#modal-search-repositories"]')
      expect(page).to have_selector('#modal-search-repositories-selections')
      expect(page).to have_selector('#modal-search-repositories-selections div.modal-search-result', count: 0)
      expect(page).to have_selector('#prefs-repositories div.modal-search-result', count: 0)

      click_button "Add a repository"
      expect(page).not_to have_selector('#modal-search-repositories-results')
      click_button "Apply filter(s)"
      find('#modal-search-repositories-results')

      # find nav at top and bottom
      expect(page).to have_selector('#modal-search-repositories-results nav', count: 2)
      expect(page).to have_selector('#modal-search-repositories-results div.modal-search-result', count: 3)

      within(all("div.modal-search-result")[0]) do
        click_link 'Select'
      end 
      within(all("div.modal-search-result")[2]) do
        click_link 'Select'
      end

      click_button 'Close'
      expect(page).to have_selector('#prefs-repositories div.modal-search-result', count: 2)

      within(all('#prefs-repositories div.modal-search-result')[0]) do
        click_link 'Remove'
      end
      expect(page).to have_selector('#prefs-repositories div.modal-search-result', count: 1)
    end

    it 'Add 2 custom repositories and remove one', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      expect(page).to have_selector('div.customized_repositories div.modal-search-result', count: 0)

      click_button "Define a Custom Repository"
      expect(page).to have_selector('#save_custom_repository:disabled')

      find('#template_custom_repo_name').set('Name 1')
      find('#template_custom_repo_description').set('Description 1')
      expect(page).to have_selector('#save_custom_repository:disabled')
      find('#template_custom_repo_uri').set('Url 1')
      expect(page).to have_selector('#save_custom_repository:enabled')
      click_button "Save Repository for Template"

      expect(page).to have_selector('div.customized_repositories div.modal-search-result', count: 1)

      click_button "Define a Custom Repository"

      find('#template_custom_repo_name').set('Name 2')
      find('#template_custom_repo_description').set('Description 2')
      find('#template_custom_repo_uri').set('Url 2')
      click_button "Save Repository for Template"

      expect(page).to have_selector('div.customized_repositories div.modal-search-result', count: 2)

      within(all('div.customized_repositories div.modal-search-result')[0]) do
        click_link 'Remove'
      end
      expect(page).to have_selector('div.customized_repositories div.modal-search-result', count: 1)
    end
  end

  describe 'Repositories Selection' do
    before do
      MetadataStandard.new(
        title: 'Metadata 1',
        description: 'Desc 1',
        uri: 'http://repo1.com'
      ).save!

      MetadataStandard.new(
        title: 'Metadata 2',
        description: 'Desc 2',
        uri: 'http://repo2.com'
      ).save!

      MetadataStandard.new(
        title: 'Metadata 3',
        description: 'Desc 3',
        uri: 'http://repo3.com'
      ).save!
    end

    it 'Select 2 metadata standards and remove one', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      expect(page).not_to have_selector('button[data-target="#modal-search-metadata-standards"]')
      expect(page).not_to have_selector('#modal-search-metadata-standards-selections')

      find('#template_customize_metadata_standards').check
      expect(page).to have_selector('button[data-target="#modal-search-metadata_standards"]')
      expect(page).to have_selector('#modal-search-metadata_standards-selections')
      expect(page).to have_selector('#modal-search-metadata_standards-selections div.modal-search-result', count: 0)
      expect(page).to have_selector('#prefs-metadata_standards div.modal-search-result', count: 0)

      click_button "Add a metadata standard"
      expect(page).not_to have_selector('#modal-search-metadat_-standards-results')
      click_button "Apply filter(s)"
      find('#modal-search-metadata_standards-results')

      # find nav at top and bottom
      expect(page).to have_selector('#modal-search-metadata_standards-results nav', count: 2)
      expect(page).to have_selector('#modal-search-metadata_standards-results div.modal-search-result', count: 3)

      within(all("div.modal-search-result")[0]) do
        click_link 'Select'
      end 
      within(all("div.modal-search-result")[2]) do
        click_link 'Select'
      end

      click_button 'Close'
      expect(page).to have_selector('#prefs-metadata_standards div.modal-search-result', count: 2)

      within(all('#prefs-metadata_standards div.modal-search-result')[0]) do
        click_link 'Remove'
      end
      expect(page).to have_selector('#prefs-metadata_standards div.modal-search-result', count: 1)
    end
  end

  describe 'Licenses Selection' do
    before do
      License.new(
        name: 'License 1',
        identifier: '1.0',
        uri: 'http://repo1.com'
      ).save!

      License.new(
        name: 'License 2',
        identifier: '2.0',
        uri: 'http://repo2.com'
      ).save!

      License.new(
        name: 'License 3',
        identifier: '3.0',
        uri: 'http://repo3.com'
      ).save!

      # Add values that will match preferred list
      License.new(
        name: 'CC-BY-1.0',
        identifier: 'CC-BY-1.0',
        uri: 'http://repo3.com'
      ).save!

      License.new(
        name: 'CC-BY-SA-1.0',
        identifier: 'CC-BY-SA-1.0',
        uri: 'http://repo3.com'
      ).save!
    end

    it 'Licenses Selection', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'
  
      click_button 'Actions'
      click_link 'Edit'
  
      click_link 'Preferences'
  
      find('#customize_licenses_sel').find('option[value="1"]').select_option
      expect(page).not_to have_selector('#default-licenses')
      expect(page).to have_selector('#my-licenses')

      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#default-licenses')
      expect(page).not_to have_selector('#my-licenses')  
  
      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#default-licenses')
      expect(page).not_to have_selector('#my-licenses')
  
      PL = License.preferred.length
      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#default-licenses li', count: PL)
  
      # Retain default values when switching to "my" values
      find('#customize_licenses_sel').find('option[value="1"]').select_option
      expect(page).to have_selector('#my-licenses li', count: PL)
  
      find('#new_license').find('option[value="1"]').select_option
      click_button _('Add a license')
      expect(page).to have_selector('#my-licenses li', count: PL + 1)
  
      find('#new_license').find('option[value="2"]').select_option
      click_button _('Add a license')
      expect(page).to have_selector('#my-licenses li', count: PL + 2)
  
      # disallow duplicate value
      find('#new_license').find('option[value="2"]').select_option
      click_button _('Add a license')
      expect(page).to have_selector('#my-licenses li', count: PL + 2)
  
      # delete one standard selection
      find('#my-licenses li.standard a.license_remove', match: :first).click
      expect(page).to have_selector('#my-licenses li', count: PL + 2 - 1)
  
      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#my-licenses li', count: 0)
    end
  end
end
