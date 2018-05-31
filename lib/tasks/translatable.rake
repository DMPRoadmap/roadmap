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
  
  
  desc 'Find all translatable text and update po files' 
  task :find, [:code] => [:environment] do |t, args|
    app_pot_filename = 'config/locale/app.pot'
    translatables = []
    
    puts "Scanning files for translatable text"
    files_to_translate.each do |file|
      # Ignore node_modules files
      unless file.include?('node_modules')
        puts "    scanning #{file}"
        translatables << scan_for_translations(File.read(file))
      end
    end
 
    translatables = translatables.flatten.uniq.sort{ |a,b| a <=> b }
    unless translatables.empty?
      process_po_file(app_pot_filename, translatables)
    
      puts "Searching for localization files"
      localization_files.each do |app_po|
        process_po_file(app_po, translatables)
      end
    else
      puts "No translatable text found!"
    end
  end
  
  MSGID = /msgid[\s]+\"(.*)\"/
  MSGSTR = /msgstr[\s]+\"(.*)\"/
  TRANSLATABLE = /_\(.*?\)/
  FUZZY = /#, fuzzy/
  
  def process_po_file(file_name, translatable_text)
    puts "Backing up original #{file_name} --> #{file_name}.bak"
    cp(file_name, "#{file_name}.bak")
    
    puts "Reading #{file_name} ..."
    file = File.read(file_name)
    header, hash = po_to_hash(file)
    
    consolidate_translatables(hash, translatable_text)
    update_revision_date(header)

    puts "Updating #{file_name} file"
    File.open(file_name, 'w') do |file|
      file.write "#{update_revision_date(header)}\n#{hash_to_po(hash)}"
    end
  end
  
  def po_to_hash(file)
    hash = {}
    if file.present?
      # split the file into sections based on the blank line separator
      chunks = file.to_s.split(/[\r\n]{2}/) 
      chunks.each do |chunk|
        if chunk.match(MSGID)
          msgid = chunk.match(MSGID).to_s.sub(/^msgid\s\"/, '').sub(/\"$/, '')
          msgstr = chunk.match(MSGSTR).to_s.sub(/^msgstr\s\"/, '').sub(/\"$/, '')
          if hash[msgid].present?
            puts "WARNING: Skipping duplicate msgid in app.pot -> '#{msgid}'"
          else
            hash[msgid] = { text: msgstr, fuzzy: chunk.match(FUZZY) ? true : false }
          end
        end
      end
    end
    # Return the header portion of the original file and the resulting msgid/msgstr hash
    return chunks[0], hash
  end
  
  def hash_to_po(hash)
    lines = ""
    hash.keys.each do |key|
      if key != ''
        if hash[key][:obsolete]
          lines += "\n#msgid \"#{key.gsub('"', '\\"')}\"\n#msgstr \"#{hash[key][:text].gsub('"', '\\"')}\"\n"
        elsif hash[key][:fuzzy]
          lines += "\n#, fuzzy\nmsgid \"#{key.gsub('"', '\\"')}\"\nmsgstr \"#{hash[key][:text].gsub('"', '\\"')}\"\n"
        else
          lines += "\nmsgid \"#{key.gsub('"', '\\"')}\"\nmsgstr \"#{hash[key][:text].gsub('"', '\\"')}\"\n"
        end
      end
    end
    lines
  end
  
  def scan_for_translations(file)
    file.to_s.scan(TRANSLATABLE).map do |text|
      text.sub(/^_\([\'\"]/, '').sub(/[\'\"]\)$/, '')
    end
  end

  def consolidate_translatables(hash, translatables)
    # Add any new translatables
    translatables.each do |text|
      unless hash[text].present?
        hash[text] = { text: "", fuzzy: true }
      end
    end
    # Mark any msgid in the hash that no longer exists in translatables
    hash.keys.each do |entry|
      unless translatables.include?(entry)
        hash[entry] = hash[entry].merge({ obsolete: true })
      end
    end
    return hash
  end

  def files_to_translate
    Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,md,haml,slim,rhtml}")
  end
  
  def localization_files
    Dir.glob("{config/locale}/**/app.po")
  end
  
  def update_revision_date(header_text)
    return header_text.include?('"PO-Revision-Date:') ? header_text.sub(/\"PO\-Revision\-Date\:.*\n/, "\"PO-Revision-Date: #{Time.now.to_s.sub(' -', '-')}\\n\"\n") : header_text
  end
end
