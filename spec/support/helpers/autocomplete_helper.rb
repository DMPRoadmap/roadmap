# frozen_string_literal: true

module AutoCompleteHelper
  def select_an_org(autocomplete_id, org)
    # Set the Org Name
    find(autocomplete_id).set org.name
    sleep(0.3)

    # The controllers are expecting the org_id though, so lets
    # populate it
    hidden_id = autocomplete_id.gsub('_name', '_id').gsub('#', '')
    hash = { id: org.id, name: org.name }.to_json

    js = "document.getElementById('#{hidden_id}').value = '#{hash}'"
    page.execute_script(js) if hidden_id.present?
  end

  def choose_suggestion(typeahead_id, org)
    # fill_in(:org_org_name, with: org.name)
    fill_in(typeahead_id.to_sym, with: org.name)

    id = typeahead_id.gsub('_name', '_id')
    # Some unfortunate hacks to deal with naming inconsistencies on the create plan page
    # and the Super Admin merge orgs tab
    id = id.gsub('org_org_', 'org_').gsub('funder_org_', 'funder_')
    # Excape any single quotes so it doesn't blow up our JS
    hash = { id: org.id, name: org.name.gsub("'", '') }
    # Capybara/Selenium can't interact with a hidden field because the user can't,
    # so use some JS to set the value
    page.execute_script "document.getElementById('#{id}').value = '#{hash.to_json}';"
  end
end
