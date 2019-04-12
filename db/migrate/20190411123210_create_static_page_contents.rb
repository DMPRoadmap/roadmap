class CreateStaticPageContents < ActiveRecord::Migration
  def change
    create_table :static_page_contents do |t|
      t.string :title
      t.text :content
      t.belongs_to :static_page, index: true, foreign_key: true, null: false
      t.belongs_to :language, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end