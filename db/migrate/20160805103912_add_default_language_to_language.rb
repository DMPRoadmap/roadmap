class AddDefaultLanguageToLanguage < ActiveRecord::Migration[4.2]
  def change
    add_column :languages, :default_language, :boolean
  end
end
