namespace :translatable do
  desc 'Add the specified language to the database'
  task :add_language_to_db, [:code, :name, :is_default] => [:environment] do |t, args|
    if args[:code].present? && args[:name].present?
      if Language.find_by(abbreviation: args[:code]).present?
        puts "That language already exists!"
      else
        Language.create!(abbreviation: args[:code], description: '', name: args[:name], default_language: (args[:is_default] == 1))
        puts "Language added"
      end
    else
      puts "You must provide a ISO-639 language code, name: `rails translatable:add_language[ja,日本語]`"
    end
  end

  desc 'Remove the specified language from the database'
  task :remove_language_from_db, [:code] => [:environment] do |t, args|
    if args[:code].present?
      lang = Language.find_by(abbreviation: args[:code])
      default = Language.find_by(default_language: true) || Language.first

      if lang.present?
        # Set any users/orgs who had the language to the default
        User.where(language_id: lang.id).update_all(language_id: default.present? ? default.id : nil)
        Org.where(language_id: lang.id).update_all(language_id: default.present? ? default.id : nil)
        lang.destroy
        puts "The language has been removed."
      else
        puts "That language is not registered!"
      end
    else
      puts "You must provide the ISO-639 language code for the language: e.g. `translatable:remove_language[ja]`"
    end
  end

end
