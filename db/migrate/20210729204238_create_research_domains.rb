class CreateResearchDomains < ActiveRecord::Migration[5.2]
  def change
    create_table :research_domains do |t|
      t.string :identifier, null: false
      t.string :label, null: false
      t.references :parent, foreign_key: { to_table: :research_domains }
      t.timestamps
    end

    add_reference :plans, :research_domain, index: true
  end
end
