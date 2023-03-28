class TemplateLicenses < ActiveRecord::Migration[6.1]
  def change
    create_table :template_licenses do |t|
      t.belongs_to :template, type: :integer, foreign_key: true, index: true
      t.belongs_to :license, foreign_key: true, index: true
    end
  end
end
