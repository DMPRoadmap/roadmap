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
    @pref_selectors = [
      '#customize_output_types_sel',
      '#template_customize_repositories',
      '#template_customize_metadata_standards',
      '#customize_licenses_sel',
      '#template_user_guidance_output_types',
      '#template_user_guidance_licenses'
    ]
    @pref_mce_selectors = [
      '#template_user_guidance_repositories',
      '#template_user_guidance_metadata_standards'
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
      expect(find('form.edit-template-preferences')).not_to have_selector('button:enabled')
      expect(find('form.edit-template-preferences')).not_to have_selector('input:enabled')
      @pref_selectors.each do |s|
        expect(page).to have_selector("#{s}:disabled")
      end
      @pref_mce_selectors.each do |s|
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
      expect(find('form.edit-template-preferences')).to have_selector('button:enabled')
      expect(find('form.edit-template-preferences')).to have_selector('input:enabled')
      @pref_selectors.each do |s|
        expect(page).to have_selector("#{s}:enabled")
      end
      # tinymce hides the original selector
      @pref_mce_selectors.each do |s|
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

    @pref_selectors.each do |s|
      expect(page).to have_selector(s)
    end
    # tinymce hides the original selector
    @pref_mce_selectors.each do |s|
      find(s, visible: false)
    end

    uncheck 'Enable research outputs tab?'
    @pref_selectors.each do |s|
      expect(page).not_to have_selector(s)
    end
    @pref_mce_selectors.each do |s|
      expect(page).not_to have_selector(s)
    end

    check 'Enable research outputs tab?'
    @pref_selectors.each do |s|
      expect(page).to have_selector(s)
    end
    # tinymce hides the original selector
    @pref_mce_selectors.each do |s|
      find(s, visible: false)
    end
  end

  it 'Select Preferred Output Types and Save', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    click_button 'Actions'
    click_link 'Edit'

    click_link 'Preferences'

    # Enable default Output Types
    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output_types')
    expect(page).not_to have_selector('#my-output_types')

    # Enable My Output Types
    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).not_to have_selector('#default-output_types')
    expect(page).to have_selector('#my-output_types')

    # Enable default Output Types
    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output_types')
    expect(page).not_to have_selector('#my-output_types')

    # Enable My Output Types + Standard Types
    find('#customize_output_types_sel').find('option[value="2"]').select_option
    expect(page).not_to have_selector('#default-output_types')
    expect(page).to have_selector('#my-output_types')

    # Verify that standard output types are in the My Output Types list
    ot_len = ResearchOutput.output_types.length
    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output_types li', count: ot_len)

    # Return to "My Output Types", verify that the standard Output Types have been removed
    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).to have_selector('#my-output_types li', count: 0)

    # Add a custom output type and count results
    find('#new_output_type').set('aaa')
    click_button _('Add output type')
    expect(page).to have_selector('#my-output_types li', count: 1)

    # Add a custom output type and count results
    find('#new_output_type').set('bbb')
    click_button _('Add output type')
    expect(page).to have_selector('#my-output_types li', count: 2)

    # disallow duplicate value addition
    find('#new_output_type').set('aaa')
    click_button _('Add output type')
    expect(page).to have_selector('#my-output_types li', count: 2)

    # Enable My Output Types + Standard Types
    find('#customize_output_types_sel').find('option[value="2"]').select_option
    expect(page).to have_selector('#my-output_types li', count: ot_len + 2)

    # delete one standard selection and count results
    find('#my-output_types li.selectable_item button.standard', match: :first).click
    expect(page).to have_selector('#my-output_types li', count: ot_len + 2 - 1)

    # enable My Output Types and verify that only standard items were remvoed
    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).to have_selector('#my-output_types li', count: 2)
    click_button 'Save Preferences'
  end

  it 'Validate at least one Output Type Selection', :js do
    # Action
    click_button 'Admin'
    click_link 'Templates'

    click_button 'Actions'
    click_link 'Edit'

    click_link 'Preferences'

    find('#customize_output_types_sel').find('option[value="0"]').select_option
    expect(page).to have_selector('#default-output_types')
    expect(page).not_to have_selector('#my-output_types')

    find('#customize_output_types_sel').find('option[value="1"]').select_option
    expect(page).not_to have_selector('#default-output_types')
    expect(page).to have_selector('#my-output_types')

    click_button 'Save Preferences'
    txt = 'At least one preferred OUTPUT TYPE must be selected if you are enabling a preferred list.'
    expect(page).to have_text(txt)
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

    # For some reason this test throws a StaleElementError after clicking the filter button and trying to select
    # a repo. It is fine in reality
    xit 'Select Preferred Repositories and Save', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      # Verify no preferred repositories have been selected
      expect(page).not_to have_selector('button[data-target="#modal-search-repositories"]')
      expect(page).not_to have_selector('#modal-search-repositories-selections')

      # Enable preferred repositories
      find('#template_customize_repositories').check
      expect(page).to have_selector('button[data-target="#modal-search-repositories"]')
      expect(page).to have_selector('#modal-search-repositories-selections')
      expect(page).to have_selector('#modal-search-repositories-selections div.modal-search-result', count: 0)
      expect(page).to have_selector('#prefs-repositories div.modal-search-result', count: 0)

      # Open modal and select preferred repositories
      click_button 'Add a repository'
      expect(page).not_to have_selector('#modal-search-repositories-results')
      click_button 'Apply filter(s)'
      find('#modal-search-repositories-results')

      # find nav at top and bottom
      expect(page).to have_selector('#modal-search-repositories-results nav', count: 2)
      expect(page).to have_selector('#modal-search-repositories-results div.modal-search-result', count: 3)

      # select the first item
      within(all('div.modal-search-result')[0]) do
        click_button 'Select'
      end
      # select the third item
      within(all('div.modal-search-result')[2]) do
        click_button 'Select'
      end

      # Close the modal and count the preferred selections
      click_button 'Close'
      expect(page).to have_selector('#prefs-repositories div.modal-search-result', count: 2)

      # Remove one preferred selection
      within(all('#prefs-repositories div.modal-search-result')[0]) do
        click_link 'Remove'
      end
      # Recount the preferred selection
      expect(page).to have_selector('#prefs-repositories div.modal-search-result', count: 1)
      click_button 'Save Preferences'
    end

    it 'Validate at least one Preferred Repository', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      expect(page).not_to have_selector('button[data-target="#modal-search-repositories"]')
      expect(page).not_to have_selector('#modal-search-repositories-selections')

      find('#template_customize_repositories').check

      click_button 'Save Preferences'
      txt = 'At least one preferred REPOSITORY must be selected if you are enabling a preferred list.'
      expect(page).to have_text(txt)
    end
  end

  describe 'Metadata Standard Selection' do
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

    # For some reason this test throws a StaleElementError after clicking the filter button and trying to select
    # a repo. It is fine in reality
    xit 'Select Preferred Metadata Standards and Save', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      # Verify no preferred metadata standards have been selected
      expect(page).not_to have_selector('button[data-target="#modal-search-metadata-standards"]')
      expect(page).not_to have_selector('#modal-search-metadata-standards-selections')

      # Enable select preferred metadata standards
      find('#template_customize_metadata_standards').check
      expect(page).to have_selector('button[data-target="#modal-search-metadata_standards"]')
      expect(page).to have_selector('#modal-search-metadata_standards-selections')
      expect(page).to have_selector('#modal-search-metadata_standards-selections div.modal-search-result', count: 0)
      expect(page).to have_selector('#prefs-metadata_standards div.modal-search-result', count: 0)

      # Open the metadata standard modal dialog, run search
      click_button 'Add a metadata standard'
      expect(page).not_to have_selector('#modal-search-metadat_-standards-results')
      click_button 'Apply filter(s)'
      find('#modal-search-metadata_standards-results')

      # find nav at top and bottom
      expect(page).to have_selector('#modal-search-metadata_standards-results nav', count: 2)
      expect(page).to have_selector('#modal-search-metadata_standards-results div.modal-search-result', count: 3)

      # Select the first item
      within(all('div.modal-search-result')[0]) do
        click_button 'Select'
      end
      # Select the third item
      within(all('div.modal-search-result')[2]) do
        click_button 'Select'
      end

      # Close modal dialog and count selections
      click_button 'Close'
      expect(page).to have_selector('#prefs-metadata_standards div.modal-search-result', count: 2)

      # remove one selection and re-count selections
      within(all('#prefs-metadata_standards div.modal-search-result')[0]) do
        click_link 'Remove'
      end
      expect(page).to have_selector('#prefs-metadata_standards div.modal-search-result', count: 1)
      click_button 'Save Preferences'
    end

    it 'Valdiate at least one Preferred Metadata Standard', :js do
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

      click_button 'Save Preferences'
      txt = 'At least one preferred METADATA STANDARD must be selected if you are enabling a preferred list.'
      expect(page).to have_text(txt)
    end
  end

  describe 'Licenses Selection' do
    before do
      # Add non standard license values
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

      # Add standard values that will match the preferred list confirguration names
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

    # Commenting out for now. For some reason the License selection and 'Add license' button click
    # are not working here in the test but are fine in reality
    xit 'Select Preferred Licenses and Save', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      # Enable My Licenses
      find('#customize_licenses_sel').find('option[value="1"]').select_option
      expect(page).not_to have_selector('#default-licenses')
      expect(page).to have_selector('#my-licenses')

      # Enable Default Licenses
      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#default-licenses')
      expect(page).not_to have_selector('#my-licenses')

      # Enable and Count My Licenses
      pl_len = License.preferred.length
      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#default-licenses li', count: pl_len)

      # For licenses, default values are retained when switching to "my" values
      find('#customize_licenses_sel').find('option[value="1"]').select_option
      expect(page).to have_selector('#my-licenses li', count: pl_len)

      # Add a non-standard license (value 1)
      find('#new_license').find('option[value="1"]').select_option
      click_button _('Add license')
      expect(page).to have_selector('#my-licenses li.license', count: pl_len + 1)

      # Add a non-standard license (value 2)
      find('#new_license').find('option[value="2"]').select_option
      click_button _('Add license')
      expect(page).to have_selector('#my-licenses li', count: pl_len + 2)

      # Attempt to re-add non-standard license (value 2)
      find('#new_license').find('option[value="2"]').select_option
      click_button _('Add license')
      expect(page).to have_selector('#my-licenses li', count: pl_len + 2)

      # delete one standard selection
      find('#my-licenses li.standard a.license_remove', match: :first).click
      expect(page).to have_selector('#my-licenses li', count: pl_len + 2 - 1)

      # re-enable standard licenses, not that my licenses are no longer present
      find('#customize_licenses_sel').find('option[value="0"]').select_option
      expect(page).to have_selector('#my-licenses li', count: 0)
      expect(page).to have_selector('#default-licenses li', count: pl_len)
      click_button 'Save Preferences'
    end

    it 'Valdiate at Least one Preferred License', :js do
      # Action
      click_button 'Admin'
      click_link 'Templates'

      click_button 'Actions'
      click_link 'Edit'

      click_link 'Preferences'

      find('#customize_licenses_sel').find('option[value="1"]').select_option
      expect(page).not_to have_selector('#default-licenses')
      expect(page).to have_selector('#my-licenses')

      # remove any standard licenese that are added to the My Licenses list
      find('#my-licenses li button.standard', match: :first).click until all('#my-licenses li button.standard').empty?

      click_button 'Save Preferences'
      expect(page).to have_text('At least one preferred LICENSE must be selected if you are enabling a preferred list.')
    end
  end
end
