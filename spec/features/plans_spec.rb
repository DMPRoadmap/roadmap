# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Plans', type: :feature do
  include Webmocks

  before do
    # @default_template = create(:template, :default, :published)
    @org = create(:org)
    @funding_org1  = create(:org, :funder, name: 'Test Funder Org1', templates: 1)
    @funding_org2  = create(:org, :funder, name: 'Test Funder Org2', templates: 1)

    @global_template = create(:template, :default, :published)
    @org_template = create(:template, :published, org: @org)

    @user = create(:user, org: @org)
    sign_in(@user)

    stub_openaire

    #     OpenURI.expects(:open_uri).returns(<<~XML
    #       <form-value-pairs>
    #         <value-pairs value-pairs-name="H2020projects" dc-term="relation">
    #           <pair>
    #             <displayed-value>
    #               115797 - INNODIA - Translational approaches to disease modifying therapy of ...
    #             </displayed-value>
    #             <stored-value>info:eu-repo/grantAgreement/EC/H2020/115797/EU</stored-value>
    #           </pair>
    #         </value-pairs>
    #       </form-value-pairs>
    #     XML
    #     )
  end

  it 'User creates a new Plan', :js do
    click_link 'Create plan'

    # Expect to have 4 templates available
    within(:xpath, "//fieldset[./legend[contains(., 'Select a DMP template')]]") do
      expect(page).to have_css('.form-check-input', count: 4)
      expect(page).to have_content(@global_template.title)
      expect(page).to have_content(@org_template.title)

      within(:xpath,
             ".//div[contains(@class,'form-label')][contains(., 'Global Templates:')]/following-sibling::div[1]") do
        expect(page).to have_css('.form-check-input', count: 1)
      end
      # Expect 1 template under form-label 'Your Organisation's Templates:'
      # rubocop:disable Layout/LineLength
      within(:xpath,
             ".//div[contains(@class,'form-label')][contains(., \"Your Organisation's Templates:\")]/following-sibling::div[1]") do
        expect(page).to have_css('.form-check-input', count: 1)
      end
      # rubocop:enable Layout/LineLength
      # Expect 2 template under form-label 'Funder Templates:'
      within(:xpath,
             ".//div[contains(@class,'form-label')][contains(., \"Funder Templates:\")]/following-sibling::div[1]") do
        expect(page).to have_css('.form-check-input', count: 1)
      end
    end

    fill_in 'plan[title]', with: 'My test plan'

    within(:xpath, "//fieldset[./legend[contains(., 'Select a DMP template')]]") do
      find('.form-check-input', match: :first).click
    end

    click_button 'Create'

    # Expectations
    expect(@user.plans).to be_one
    @plan = Plan.last
    expect(current_path).to eql(plan_path(@plan))
    expect(page).to have_css("input[type=text][value='#{@plan.title}']")
    expect(@plan.title).to eql('My test plan')
  end
end
