class PostMadmpCleanup < ActiveRecord::Migration[5.2]
  def change
    # Remove temporary flags that were used to restrict maDMP functionality to a few tester orgs and templates
    remove_column :templates, :allow_research_outputs
    remove_column :orgs, :allow_doi

    # Decided not to ask users for the mime type when defining research outputs
    drop_table :mime_types
    remove_column :research_outputs, :mime_type_id

    # Remove attributes found in the RDA common standard that we decided not to use
    remove_column :research_outputs, :mandatory_attribution
    remove_column :research_outputs, :coverage_region
    remove_column :research_outputs, :coverage_start
    remove_column :research_outputs, :coverage_end

    # Research outputs can now have multiple repositories which are stored in repositories_research_outputs
    remove_column :research_outputs, :repository_id

    # Plans now have a subscriptions association so that they can have multiple api_clients
    remove_column :plans, :api_client_id
  end
end
