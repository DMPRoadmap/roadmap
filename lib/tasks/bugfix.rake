namespace :bugfix do

  desc "Bug fixes for version v0.3.3"
  task v0_3_3: :environment do
    Rake::Task['bugfix:fix_question_formats'].execute
    Rake::Task['bugfix:add_missing_token_permission_types'].execute
  end

  desc "Add the missing formattype to the question_formats table"
  task fix_question_formats: :environment do
    QuestionFormat.all.each do |qf|
      case qf.title.downcase
      when 'text area'
        qf.formattype = :textarea
      when 'text field'
        qf.formattype = :textfield
      when 'radio buttons'
        qf.formattype = :radiobuttons
      when 'check box'
        qf.formattype = :checkbox
      when 'dropdown'
        qf.formattype = :dropdown
      when 'multi select box'
        qf.formattype = :multiselectbox
      when 'date'
        qf.formattype = :date
      end
      
      qf.save!
    end
    
    if QuestionFormat.find_by(formattype: :date).nil?
      QuestionFormat.create!({title: "Date", option_based: true, formattype: 6})
    end
  end

  desc "Add the missing token_permission_types"
  task add_missing_token_permission_types: :environment do
    if TokenPermissionType.find_by(token_type: 'templates').nil?
      TokenPermissionType.create!({token_type: 'templates', 
                                   text_description: 'allows a user access to the templates api endpoint'})
    end
    if TokenPermissionType.find_by(token_type: 'statistics').nil?
      TokenPermissionType.create!({token_type: 'statistics', 
                                   text_description: 'allows a user access to the statistics api endpoint'})
    end
  end

end