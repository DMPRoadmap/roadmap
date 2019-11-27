namespace :gettext do
  def files_to_translate
    Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,md,haml,slim,rhtml}")
  end
  
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
      puts "You must provide a ISO-639 language code, name: rake gettext:add_language[ja,日本語]"
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
      puts "You must provide the ISO-639 language code for the language: e.g. gettext:remove_language[ja]"
    end
  end
  
  desc 'Find diffs between main app.pot and specified locale'
  task :diffs, [:code] => [:environment] do |t, args|
    if args[:code].present?
      locale_file = "config/locale/#{args[:code]}/app.po"
      msgids, orphaned = [], []
      
      puts "scanning config/locale/app.pot for msgids ..."
      File.open('config/locale/app.pot').each do |line|
        if line.start_with?('msgid ')
          msgids << line unless msgids.include?(line)
        end
      end
      
      puts "comparing msgids with those in #{locale_file} ..."
      File.open(locale_file).each do |line|
        if line.start_with?('msgid ')
          if msgids.include?(line)
            msgids.delete_if{ |id| id == line }
          else
            orphaned << line
          end
        end
      end
      
      puts "The following msgids were found in the core app.pot file but NOT in the #{args[:code]} version:"
      msgids.map{ |id| puts "\n\t#{id}" }
      puts "---------------------------------------------------------------------"
      puts "The following msgids appear in the #{args[:code]} file but NOT in the core app.pot. They may be obsolete:"
      orphaned.map{ |id| puts "\n\t#{id}" }
    else
      puts "You must specify a locale code (e.g. en_US or fr)"
    end
  end
end
