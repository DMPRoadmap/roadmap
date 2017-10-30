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

  desc "remove duplicate answers"
  task remove_duplicate_answers: :environment do
    dupes = Answer.select("answers.id, a2.id AS id2, answers.updated_at, a2.updated_at as updated_at2, answers.text, a2.text as text2").from("answers JOIN answers as a2 ON answers.question_id = a2.question_id AND answers.plan_id = a2.plan_id AND answers.id < a2.id" )
    dupes.each do |dupe|
      # pull over the notes from a2
      Note.where(answer_id: dupe.id2).each do |note|
        note.answer_id = dupe.id
        note.save!
      end
      # remove any question_options
      QuestionOptions.delete(answer.question_options.map{|qo| qo.id})
      # remove the duplicate ansewr
      Answer.delete(dupe.id2)
    end
  end

  desc "init answers for all questions"
  task init_answers_for_all_questions_of_plans: :environment do
    Plan.include(:questions).for_each do |plan|
      Plan.questions.each do |q|
        # ensure an answer exists or create
        unless Answer.where(plan_id: plan.id, question_id: q.id).present?
          Answer.new(plan_id: plan.id, question_id: q.id).save!          
        end
      end
    end
  end



end
