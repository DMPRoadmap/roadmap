# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OrgAutocomplete' do
  include Helpers::DmptoolHelper

  # Generic Tests for the Org Autocomplete form widget as well as tests for each
  # implementation of it throughout the site
  before do
    mock_blog
    @org = create(:org, :institution, managed: true)
    @funder = create(:org, :funder, managed: true)
    @plan = create(:plan, :creator)
    @user = @plan.owner
    @word = 'Example'

    # rubocop:disable Layout/LineLength
    @warn_with_custom = _('Please select an item from the list or check the box below and provide a name for your institution.')
    # rubocop:enable Layout/LineLength
    @warn_without_custom = _('Please select an item from the list.')

    # Sign in and go to the Edit Project Details page
    sign_in @user
  end

  it 'Setting restrict_orgs flag in config disables custom org entry', js: true do
    original_restrict = Rails.configuration.x.application.restrict_orgs
    Rails.configuration.x.application.restrict_orgs = true
    visit plan_path(@plan)

    within('#funder-org-controls') do
      expect(find('label[for="org_autocomplete_funder_name"]').present?).to be(true)
      expect(find_by_id('org_autocomplete_funder_name').present?).to be(true)
      expect { find_by_id('org_autocomplete_funder_not_in_list') }.to raise_error(Capybara::ElementNotFound)
      expect { find_by_id('org_autocomplete_funder_user_entered_name') }.to raise_error(Capybara::ElementNotFound)
      expect(find('.autocomplete-help').present?).to be(true)

      id = find_by_id('org_autocomplete_funder_name')[:list].split('-').last
      expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
      expect(page).not_to have_text(@warn_without_custom)
      expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

      fill_in 'Funder', with: Faker::Company.unique.name
    end

    # fill in a different field to trigger the validation check
    fill_in 'Project title', with: Faker::Lorem.sentence
    expect(page).to have_text(@warn_without_custom)
    Rails.configuration.x.application.restrict_orgs = original_restrict
  end

  context 'basic autocomplete functionality' do
    before do
      original_restrict = Rails.configuration.x.application.restrict_orgs
      Rails.configuration.x.application.restrict_orgs = false
      sign_out @user
      visit root_path
      fill_in 'Email address', with: Faker::Internet.unique.email
      click_on 'Continue'

      expect(page).to have_text(_('Sign up'))

      @selector = '#sign-up-org'
      Rails.configuration.x.application.restrict_orgs = original_restrict
    end

    it 'User can type in the autocomplete and see suggestions', :js do
      org = create(:org)
      # Fill in the autocomplete and then fill in another field to ensure JS runs
      select_an_org(@selector, org.name, 'Institution')
      fill_in 'First Name', with: Faker::Movies::StarWars.character
      expect(page).not_to have_text(@warn_with_custom)
    end

    it 'User can specify their own custom Org', :js do
      # Fill in the custom name and then fill in another field to ensure JS runs
      enter_custom_org(@selector, Faker::Company.name)
      fill_in 'First Name', with: Faker::Movies::StarWars.character
      expect(page).not_to have_text(@warn_with_custom)
    end

    it 'User cannot enter a custom Org in the autocomplete', :js do
      # Fill in the autocomplete and then fill in another field to ensure JS runs
      fill_in 'Institution', with: Faker::Company.name
      fill_in 'First Name', with: Faker::Movies::StarWars.character
      expect(page).to have_text(@warn_with_custom)
    end

    it 'Clear the custom Org name and unchecks the checkbox if user types in autocomplete', :js do
      # Fill in the custom name and then fill in another field to ensure JS runs
      enter_custom_org(@selector, Faker::Company.name)
      fill_in 'Institution', with: Faker::Company.unique.name
      expect(find_by_id('org_autocomplete_not_in_list', visible: false).value).not_to eql('1')
      expect(find_by_id('org_autocomplete_user_entered_name', visible: false).value).to eql('')
    end

    it 'Clear the entry in the autocomplete when user clicks checkbox', :js do
      org = create(:org)
      # Fill in the autocomplete and then fill in another field to ensure JS runs
      select_an_org(@selector, org.name, 'Institution')
      find('label[for="org_autocomplete_not_in_list"]').click
      expect(find_by_id('org_autocomplete_name').value).to eql('')
    end

    context 'validate that we can save the Org' do
      before do
        # Fill out the rest of the form
        fill_in 'First Name', with: Faker::Movies::StarWars.character.split.first
        fill_in 'Last Name', with: Faker::Movies::StarWars.character.split.last
        fill_in 'Password', with: SecureRandom.uuid
        # Need to use JS to set the accept terms label since dmptool-ui treats the
        # whole thing as a label and theis particular label has a URL so 'clicking' it
        # via Capybara results in going to the URL behind that link :/
        page.execute_script("document.getElementById('user_accept_terms').checked = true;")
      end

      it 'can save a selected name', js: true do
        original_user_count = User.all.count
        select_an_org(@selector, @org.name, 'Institution')
        click_button _('Sign up')
        expect(page).not_to have_errors
        expect(User.all.count).to eql(original_user_count + 1)
        expect(User.last.org.name).to eql(@org.name)
        sign_out User.last
      end

      it 'can save a custom name', js: true do
        original_user_count = User.all.count
        name = Faker::Movies::StarWars.unique.planet
        enter_custom_org(@selector, name)
        click_button _('Sign up')
        expect(page).not_to have_errors, page.body
        expect(User.all.count).to eql(original_user_count + 1)
        expect(User.last.org.name.downcase.capitalize).to eql(name.downcase.capitalize)
        sign_out User.last
      end
    end
  end

  context 'Individual implementations of the autocomplete', js: true do
    before do
      @original_restrict = Rails.configuration.x.application.restrict_orgs
      Rails.configuration.x.application.restrict_orgs = false
      init_orgs
    end

    after do
      Rails.configuration.x.application.restrict_orgs = @original_restrict
    end

    context 'Sign up page implementation works' do
      it 'has used the appropriate controls and returns the expected suggestions', :js do
        # The Autocomplete on this page should allow the user to select any Orgs
        # or RegistryOrgs and allow them to create new Orgs
        sign_out @user
        visit root_path
        fill_in 'Email address', with: 'foo@bar.edu'
        click_on 'Continue'
        expect(page).to have_text(_('Sign up'))

        within('#sign-up-org') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql('')
          expect(find_by_id('org_autocomplete_not_in_list', visible: false).present?).to be(true)
          expect(find_by_id('org_autocomplete_user_entered_name', visible: false).present?).to be(true)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in _('Institution'), with: ''
          fill_in _('Institution'), with: @word

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@org_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@registry_org.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(true)
          expect(suggestion_exists?(@associated_matched.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'Edit Profile page implementation works' do
      it 'has used the appropriate controls and returns the expected suggestions', js: true do
        # The Autocomplete on this page should allow the user to select any Orgs
        # or RegistryOrgs and allow them to create new Orgs
        visit edit_user_registration_path
        expect(page).to have_text(_('Edit Profile'))

        within('#profile-controls') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql(@user.org.name)
          expect(find_by_id('org_autocomplete_not_in_list', visible: false).present?).to be(true)
          expect(find_by_id('org_autocomplete_user_entered_name', visible: false).present?).to be(true)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in _('Institution'), with: ''
          fill_in _('Institution'), with: @word
          sleep(1)

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@org_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@registry_org.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(true)
          expect(suggestion_exists?(@associated_matched.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'Contributor page implementation (all orgs)' do
      it 'has used the appropriate controls and returns the expected suggestions', js: true do
        @user.update(org_id: @plan.org.id)

        # The Autocomplete on this page should allow the user to select any Orgs
        # or RegistryOrgs and allow them to create new Orgs
        visit new_plan_contributor_path(@plan)
        expect(page).to have_text(_('New contributor'))

        within('#contributor-org-controls') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql(@plan.org.name)
          expect(find_by_id('org_autocomplete_not_in_list', visible: false).present?).to be(true)
          expect(find_by_id('org_autocomplete_user_entered_name', visible: false).present?).to be(true)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in _('Affiliation'), with: ''
          fill_in _('Affiliation'), with: @word
          sleep(1)

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@org_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@registry_org.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(true)
          expect(suggestion_exists?(@associated_matched.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'Create Plan page implementation (Research Org and Funder)' do
      it 'has the appropriate controls and returns the expected suggestions', js: true do
        # The Autocompletes on this page should:
        #   Research Org: only allow known Orgs (no unassociated RegistryOrgs) and
        #                 no ability to create Orgs
        #   Funder:       only allow funder Orgs and funder RegistryOrgs. Also allow
        #                 the user to create new funders
        visit new_plan_path
        expect(page).to have_text('Create a new plan')

        within('#research-org-controls') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql(@user.org.name)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in 'Research organisation', with: ''
          fill_in 'Research organisation', with: @word
          sleep(1)

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@org_managed.name)).to be(true)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@associated_matched.name)).to be(true)

          # Make sure the funder Orgs are also suggested
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure that RegistryOrgs with no associated Org are NOT suggested
          expect(suggestion_exists?(@registry_org.name)).to be(false)
          expect(suggestion_exists?(@registry_funder.name)).to be(false)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end

        within('#funder-org-controls') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_funder_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_funder_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_funder_name').value).to eql('')
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_funder_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in 'Funder', with: ''
          fill_in 'Funder', with: @word

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(false)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure the non-funder Orgs are NOT suggested
          expect(suggestion_exists?(@org_managed.name)).to be(false)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(false)
          expect(suggestion_exists?(@registry_org.name)).to be(false)
          expect(suggestion_exists?(@associated_matched.name)).to be(false)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'Project Details page implementation (Funder only)' do
      it 'has the appropriate controls and returns the expected suggestions', js: true do
        # The Autocomplete on this page should only allow the selection of funder
        # Org or RegistryOrg records and also allow the user to create funders
        visit plan_path(@plan)
        expect(page).to have_text('Project Start')

        within('#funder-org-controls') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_funder_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_funder_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_funder_name').value).to eql('')
          expect(find_by_id('org_autocomplete_funder_not_in_list', visible: false).present?).to be(true)
          expect(find_by_id('org_autocomplete_funder_user_entered_name', visible: false).present?).to be(true)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_funder_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in 'Funder', with: ''
          fill_in 'Funder', with: @word

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure the non-funder Orgs are NOT suggested
          expect(suggestion_exists?(@org_managed.name)).to be(false)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(false)
          expect(suggestion_exists?(@registry_org.name)).to be(false)
          expect(suggestion_exists?(@associated_matched.name)).to be(false)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'Templates page for letting SuperAdmin change affiliations' do
      it 'has the appropriate controls and returns the expected suggestions', js: true do
        # The Autocomplete on this page should only allow the SuperAdmin to select
        # known Orgs (no unassociated RegistryOrgs) and no ability to create Orgs
        sign_out @user
        super_admin = create(:user, :super_admin)
        sign_in super_admin
        visit org_admin_templates_path
        expect(page).to have_text('Templates')

        within('#super-admin-switch-org') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql(super_admin.org.name)
          expect { find_by_id('org_autocomplete_not_in_list') }.to raise_error(Capybara::ElementNotFound)
          expect do
            find_by_id('org_autocomplete_user_entered_name', visible: false)
          end.to raise_error(Capybara::ElementNotFound)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in 'Affiliation', with: ''
          fill_in 'Affiliation', with: @word
          sleep(1)

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@org_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@associated_matched.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure that RegistryOrgs with no associated Org are NOT suggested
          expect(suggestion_exists?(@registry_org.name)).to be(false)
          expect(suggestion_exists?(@registry_funder.name)).to be(false)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(false)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(false)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'SuperAdmin Editing a User page implementation works' do
      it 'has used the appropriate controls and returns the expected suggestions', js: true do
        # The Autocomplete on this page should allow the SuperAdmin to select any Orgs
        # or RegistryOrgs and allow them to create new Orgs
        sign_out @user
        super_admin = create(:user, :super_admin)
        sign_in super_admin
        visit edit_super_admin_user_path(@user)
        expect(page).to have_text("#{'Editing profile for'} #{@user.name(false)}")

        within('#super-admin-user-org-controls') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql(@user.org.name)
          expect(find_by_id('org_autocomplete_not_in_list', visible: false).present?).to be(true)
          expect(find_by_id('org_autocomplete_user_entered_name', visible: false).present?).to be(true)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in 'Institution', with: ''
          fill_in 'Institution', with: @word
          sleep(1)

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@org_managed.name)).to be(true)
          expect(suggestion_exists?(@funder_managed.name)).to be(true)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(true)
          expect(suggestion_exists?(@registry_org.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(true)
          expect(suggestion_exists?(@associated_matched.name)).to be(true)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(true)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end

    context 'SuperAdmin Create an Organisation page implementation works' do
      it 'has used the appropriate controls and returns the expected suggestions', js: true do
        # The Autocomplete on this page should allow the SuperAdmin to only select
        # unassociated RegistryOrgs OR add a custom Org
        sign_out @user
        super_admin = create(:user, :super_admin)
        sign_in super_admin
        visit new_super_admin_org_path
        expect(page).to have_text('New organisation')

        within('#edit_org_profile_form') do
          # Make sure the Autocomplete controls are correct
          expect(find('label[for="org_autocomplete_name"]').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').present?).to be(true)
          expect(find_by_id('org_autocomplete_name').value).to eql('')
          expect(find_by_id('org_autocomplete_not_in_list', visible: false).present?).to be(true)
          expect(find_by_id('org_autocomplete_user_entered_name', visible: false).present?).to be(true)
          expect(find('.autocomplete-help').present?).to be(true)

          id = find_by_id('org_autocomplete_name')[:list].split('-').last
          expect(find(".autocomplete-warning-#{id}", visible: false).present?).to be(true)
          expect(find("#autocomplete-suggestions-#{id}", visible: false).present?).to be(true)

          # Clear the default Org name and replace with our search term
          fill_in 'Organisation lookup', with: ''
          fill_in 'Organisation lookup', with: @word

          # Make sure the correct Orgs are suggested
          expect(suggestion_exists?(@registry_org.name)).to be(true)
          expect(suggestion_exists?(@registry_funder.name)).to be(true)

          # Make sure known Orgs are NOT suggested
          expect(suggestion_exists?(@org_managed.name)).to be(false)
          expect(suggestion_exists?(@funder_managed.name)).to be(false)
          expect(suggestion_exists?(@org_unmanaged.name)).to be(false)
          expect(suggestion_exists?(@funder_unmanaged.name)).to be(false)
          expect(suggestion_exists?(@associated_matched.name)).to be(false)
          expect(suggestion_exists?(@associated_matched_funder.name)).to be(false)

          # Make sure the other Orgs are NOT suggested
          unmatched_never_appear?
        end
      end
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def init_orgs
    # Orgs that match the search term and have no associated Registry Org
    @funder_managed = create(:org, :funder, managed: true, name: "#{@word} Managed Funder")
    @funder_unmanaged = create(:org, :funder, managed: false, name: "#{@word} Unmanaged Funder")
    @org_managed = create(:org, managed: true, name: "#{@word} Managed Org")
    @org_unmanaged = create(:org, managed: false, name: "#{@word} Unmanaged Org")

    # RegistryOrgs that matches the search term and have no associated Org
    @registry_funder = create(:registry_org, name: "#{@word} Registry Funder")
    @registry_org = create(:registry_org, fundref_id: nil, name: "#{@word} Registry Org")

    # Orgs that match the search term and have an associated RegistryOrg that does not
    @associated_matched_funder = create(:org, :funder, name: "Matched Assoc Funder #{@word.downcase}")
    @registry_unmatched_funder = create(:registry_org, name: 'Unmatched Assoc Registry Funder',
                                                       org_id: @associated_matched_funder.id)
    @associated_matched = create(:org, name: "Matched Assoc Org #{@word.downcase}")
    @registry_unmatched = create(:registry_org, fundref_id: nil,
                                                name: 'Unmatched Assoc Registry Org',
                                                org_id: @associated_matched.id)

    # Orgs that does not match the search term but has an associated RegistryOrg that does
    @associated_unmatched_funder = create(:org, :funder, name: 'Unmatched Assoc Funder')
    @registry_matched_funder = create(:registry_org, name: "Matched Assoc Registry Funder (#{@word.downcase}.org)",
                                                     org_id: @associated_unmatched_funder.id)
    @associated_unmatched = create(:org, :funder, name: 'Unmatched Assoc Org')
    @registry_matched = create(:registry_org, fundref_id: nil,
                                              name: "Matched Assoc Registry Org (#{@word.downcase}.org)",
                                              org_id: @associated_unmatched.id)

    # Orgs and RegistryOrgs that do not match the search term
    @unmatched_funder = create(:org, managed: true, name: 'Unmatched Funder')
    @unmatched_unmanaged_funder = create(:org, managed: false, name: 'Unmatched Unmanaged Funder')
    @unmatched_registry_funder = create(:org, name: 'Unmatched Registry Funder')
    @unmatched = create(:org, managed: true, name: 'Unmatched Managed Org')
    @unmatched_unmanaged = create(:org, managed: false, name: 'Unmatched Unamanaged Org')
    @unmatched_registry = create(:registry_org, fundref_id: nil, name: 'Unmatched Registry Org')

    # Create templates for the funders
    create(:template, :published, org_id: @funder_managed.id)
    create(:template, :published, org_id: @funder_unmanaged.id)
    create(:template, :published, org_id: @associated_matched_funder.id)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # Check to ensure that none of the Orgs or RegistryOrgs that do not match the search term
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def unmatched_never_appear?
    !suggestion_exists?(@unmatched_funder.name) &&
      !suggestion_exists?(@unmatched_unmanaged_funder.name) &&
      !suggestion_exists?(@unmatched_registry_funder.name) &&
      !suggestion_exists?(@unmatched.name) &&
      !suggestion_exists?(@unmatched_unmanaged.name) &&
      !suggestion_exists?(@unmatched_registry.name) &&
      !suggestion_exists?(@registry_unmatched_funder.name) &&
      !suggestion_exists?(@registry_unmatched.name) &&
      !suggestion_exists?(@associated_unmatched.name) &&
      !suggestion_exists?(@associated_unmatched_funder.name)
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
