# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Plans', type: :feature do
  include Webmocks

  before do
    @default_template = create(:template, :default, :published)
    @org = create(:org)
    @research_org = create(:org, :organisation, :research_institute,
                           templates: 1)
    @funding_org  = create(:org, :funder, templates: 1)
    @template     = create(:template, org: @org)
    @user         = create(:user, org: @org)
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
    # TODO: Revisit this after we start refactoring/building out or tests for
    #       the new create plan workflow. For some reason the plans/new.js isn't
    #       firing here but works fine in the UI with manual testing
    # Action
    click_link 'Create plan'
    fill_in :plan_title, with: 'My test plan'
    choose_suggestion('plan_org_org_name', @research_org)

    choose_suggestion('plan_funder_org_name', @funding_org)
    click_button 'Create plan'

    # Expectations
    expect(@user.plans).to be_one
    @plan = Plan.last
    expect(current_path).to eql(plan_path(@plan))
    expect(page).to have_css("input[type=text][value='#{@plan.title}']")
    expect(@plan.title).to eql('My test plan')
    expect(@plan.org_id).to eql(@research_org.id)
    expect(@plan.funder_id).to eql(@funding_org.id)
  end
end
