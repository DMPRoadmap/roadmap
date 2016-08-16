class AddDefaultLanguageToLanguage < ActiveRecord::Migration
  def change
    add_column :languages, :default_language, :boolean
  end
end
