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

  desc 'Find all translatable text and update all pot/po files'
  task :find, [:domain] => [:environment] do |t, args|
    domain = args.fetch(:domain, 'app')
    pot_filename = "config/locale/#{domain}.pot"
    translatables = []

    puts "Scanning files for translatable text for domain: #{domain}"
    files_to_translate(domain).each do |file|
      # Ignore node_modules files
      unless file.include?('node_modules')
        puts "    scanning #{file}"
        translatables << scan_for_translations(File.read(file))
      end
    end
    translatables = translatables.flatten.uniq.sort{ |a,b,| a <=> b }

    unless translatables.empty?
      process_po_file(pot_filename, translatables)

      puts "Searching for localization files"
      localization_files(domain).each do |domain_po|
        process_po_file(domain_po, translatables)
      end
    else
      puts "No translatable text found!"
    end
  end

  MSGID = /msgid[\s]+\"(.*)\"/
  MSGSTR = /msgstr[\s]+\"(.*)\"/
  TRANSLATABLE = /(_\((.|\n)*?[\'\"]\)[\]\)\s\}\,\n\%]+)/
  CONTEXTUALIZED_TRANSLATABLE = /(n_\([\'\"](.*?)[\'\"]\,\s*[\'\"](.*?)[\'\"])/
  UNESCAPED_QUOTE = /(?<!\\)\"/
  FUZZY = /#, fuzzy/
  NEWLINE_FOR_PO = "\"\n\""

  # Open the PO/POT file and update its translatation entries
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

  # Convert the PO/POT to a hash `hash['organisation'] = { text: 'organization', fuzzy: true, obsolete: false }`
  # The fuzzy and obsolete flags get updated in `consolidate_translatables`
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

  # Convert the hash to PO/POT format
  def hash_to_po(hash)
    lines = ""
    hash.keys.sort{ |a,b| a <=> b }.each do |key|
      if key != ''
        if hash[key][:obsolete]
          lines += "\n#msgid \"#{sanitize_po_string(key)}\"\n#msgstr \"#{sanitize_po_string(hash[key][:text])}\"\n"
        elsif hash[key][:fuzzy]
          lines += "\n#, fuzzy\nmsgid \"#{sanitize_po_string(key)}\"\nmsgstr \"#{sanitize_po_string(hash[key][:text])}\"\n"
        else
          lines += "\nmsgid \"#{sanitize_po_string(key)}\"\nmsgstr \"#{sanitize_po_string(hash[key][:text])}\"\n"
        end
      end
    end
    lines
  end

  def sanitize_po_string(val)
    val.gsub(UNESCAPED_QUOTE, '\"').gsub("\n", NEWLINE_FOR_PO)
  end

  # Scan the file contents for translatable text
  def scan_for_translations(file)
    # Look for `_('text')` style markup
    translatables = file.to_s.scan(TRANSLATABLE).map do |text|
      text[0]
    end
    # Look for `n_('text', 'texts', variable)` style markup
    file.to_s.scan(CONTEXTUALIZED_TRANSLATABLE).each do |text|
      parts = text[0].split(/[\'\"]\,\s*[\'\"]/)
      translatables << parts[0] if parts[0].present?
      translatables << parts[1] if parts[1].present?
    end
    # Clean up the translatable text entries
    translatables.map do |entry|
      entry.sub(/^n?_\([\'\"]/, '').              # remove the gettext markup from front of line
        sub(/[\'\"]{1}[\)\]\}\,\s\n\%]*$/, '').   # remove the gettext markup from end of line
        gsub(/[\\]+[\"]/, "\"").                  # remove double escaped quotes (e.g. \\\")
        gsub(/[\\]+[\']/, "'").                   # remove double escaped single quotes
        gsub(/\'\\\n\s*[\'\"]/, '')               # remove line continuations
    end
  end

  # Compare the entries already logged in the PO/POT file with the translatable text
  def consolidate_translatables(hash, translatables)
    # Add any new translatables with the `#, fuzzy` prefix
    translatables.each do |text|
      unless hash[text.gsub(UNESCAPED_QUOTE, '\"')].present?
        hash[text] = { text: "", fuzzy: true }
      end
    end
    # Mark any translatations that exist in the PO/POT file but do not appear in the translatable text list as obsolete
    hash.keys.each do |entry|
      unless translatables.include?(entry.gsub('\"', '"'))
        hash[entry] = hash[entry].merge({ obsolete: true })
      end
    end
    return hash
  end

  # TODO: exclude app/views/branded
  def files_to_translate(domain)
    if domain == 'app'
      Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,md,haml,slim,rhtml}")
    else
      Dir.glob("{app/views/branded}/**/*.{rb,erb,md,haml,slim,rhtml}")
    end
  end

  def localization_files(domain)
    Dir.glob("{config/locale}/**/#{domain}.po")
  end

  # Update the PO/POT file's revision data with today's date
  def update_revision_date(header_text)
    return header_text.include?('"PO-Revision-Date:') ? header_text.sub(/\"PO\-Revision\-Date\:.*\n/, "\"PO-Revision-Date: #{Time.now.to_s.sub(' -', '-')}\\n\"\n") : header_text
  end
end
