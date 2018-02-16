namespace :initialize_data do
  desc "Add RDA Question Type"
  task rda_ques: :environment do
    rda_q_title = 'RDA Metadata Standards'
    # check if already in the database
    rda_q = QuestionFormat.find_by(title: rda_q_title)
    if rda_q.blank?
      rda_q = QuestionFormat.new()
      rda_q.title = rda_q_title
      puts 'Question format does not exist, adding'
    else
      puts 'Question format already exists, updating'
    end
    rda_q.option_based = false # keeping this false as options not stored locally
    rda_q.formattype = QuestionFormat.formattypes[:rda_metadata]
    rda_q.description = "https://dmponline-test.dcc.ac.uk/rda/api/" # TODO: Update to permanant API address once HTTPS is added
    if rda_q.save
      puts 'Sucessfully added/updated'
    else
      puts 'QuestionFormat not added/updated'
    end
  end
end
