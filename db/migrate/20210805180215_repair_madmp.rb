class RepairMadmp < ActiveRecord::Migration[5.2]
  def change
    # Rename :fos to :research_domains and drop unused columns
    rename_table :fos, :research_domains
    remove_column :research_domains, :uri
    remove_column :research_domains, :keywords
    rename_column :plans, :fos_id, :research_domain_id

    # Fix repositories columns
    rename_column :repositories, :url, :homepage
    add_column :repositories, :uri, :string, null: false, index: true
    # Run `rails dmptool_specific:transfer_re3data_ids

    # Fix licenses column
    rename_column :licenses, :url, :uri
  end
end
