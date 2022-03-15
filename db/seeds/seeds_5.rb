require 'faker'
# Create some existing plans for admins
  # ---------------------------------------------------------
  # Plans are created within 1 year for statistics

  # Plan crated by super admin, using organisational admin's org template
  (1..20).each do |index|
    template_org = Org.find_by(abbreviation: "OEO")
    title = "Test Plan " + index.to_s
    plan = {
      title: title,
      created_at: index.month.ago,
      updated_at: index.month.ago,
      template: Template.where(org_id: template_org.id).sample,
      identifier: index,
      description: Faker::Lorem.paragraph,
      visibility: [0,1,2,3].sample,
      feedback_requested: false,
      complete: false,
      org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation)
    }
    Plan.create!(plan)
    role = {
      user: User.find_by(email: "dmp.super.admin@engagedri.ca"),
      plan: Plan.find_by(title:title),
      created_at: index.month.ago,
      updated_at: index.month.ago,
      access: [8,12,14,15].sample,
      active: 1
    }
    Role.create!(role)
  end
  # Plan created by insitutional admin, using super admin's org template
  (1..20).each do |index|
    template_org = Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation)
    title = "Test Plan " + index.to_s
    plan = {
      title: title,
      created_at: index.month.ago,
      updated_at: index.month.ago,
      template: Template.where(org_id: template_org.id).sample,
      identifier: index,
      description: Faker::Lorem.paragraph,
      visibility: [0,1,2,3].sample,
      feedback_requested: false,
      complete: false,
      org: Org.find_by(abbreviation: "IEO")
    }
    Plan.create!(plan)
    role = {
      user: User.find_by(email: "dmp.insitution.admin@engagedri.ca"),
      plan: Plan.find_by(title:title),
      created_at: index.month.ago,
      updated_at: index.month.ago,
      access: [8,12,14,15].sample,
      active: 1
    }
    Role.create!(role)
  end
  # Plan created by org admin, using instutional admin's org template
  (1..20).each do |index|
    template_org = Org.find_by(abbreviation: "IEO")
    title = "Test Plan " + index.to_s
    plan = {
      title: title,
      created_at: index.month.ago,
      updated_at: index.month.ago,
      template: Template.where(org_id: template_org.id).sample,
      identifier: index,
      description: Faker::Lorem.paragraph,
      visibility: [0,1,2,3].sample,
      feedback_requested: false,
      complete: false,
      org: Org.find_by(abbreviation: "OEO")
    }
    Plan.create!(plan)
    role = {
      user: User.find_by(email: "dmp.organisation.admin@engagedri.ca"),
      plan: Plan.find_by(title:title),
      created_at: index.month.ago,
      updated_at: index.month.ago,
      access: [8,12,14,15].sample,
      active: 1
    }
    Role.create!(role)
  end

  #####################################
  ### Manually defined seed data just for sandbox testing 
  #####################################

  # Fake statistics for each of the three admin, up to 48 months back
  (1..48).each do |index|
    stat_details = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) } 
    stat_details2 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    stat_details3 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    @date = index.month.ago #date range
    @org = Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation) #the one that statistics belongs to
    @details = { "by_template": [stat_details, stat_details2], "using_template": [stat_details3] }
    stat_created_plan = {date: @date, org: @org, details: @details, filtered: 0, count:Faker::Number.number(digits: 2)}
    StatCreatedPlan.create(stat_created_plan)
    stat_shared_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatSharedPlan.create(stat_shared_plan)
    stat_joined_user = {date: @date, org: @org, count: Faker::Number.number(digits: 2)}
    StatJoinedUser.create(stat_joined_user)
    stat_exported_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatExportedPlan.create(stat_exported_plan)  
  end

  (1..48).each do |index|
    stat_details = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) } 
    stat_details2 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    stat_details3 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    @date = index.month.ago #date range
    @org = Org.find_by(abbreviation: "IEO")
    @details = { "by_template": [stat_details, stat_details2], "using_template": [stat_details3] }
    stat_created_plan = {date: @date, org: @org, details: @details, filtered: 0, count:Faker::Number.number(digits: 2)}
    StatCreatedPlan.create(stat_created_plan)
    stat_shared_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatSharedPlan.create(stat_shared_plan)
    stat_joined_user = {date: @date, org: @org, count: Faker::Number.number(digits: 2)}
    StatJoinedUser.create(stat_joined_user)
    stat_exported_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatExportedPlan.create(stat_exported_plan)
  end

  (1..48).each do |index|
    stat_details = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) } 
    stat_details2 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    stat_details3 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    @date = index.month.ago #date range
    @org = Org.find_by(abbreviation: "OEO")
    @details = { "by_template": [stat_details, stat_details2], "using_template": [stat_details3] }
    stat_created_plan = {date: @date, org: @org, details: @details, filtered: 0, count:Faker::Number.number(digits: 2)}
    StatCreatedPlan.create(stat_created_plan)
    stat_shared_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatSharedPlan.create(stat_shared_plan)
    stat_joined_user = {date: @date, org: @org, count: Faker::Number.number(digits: 2)}
    StatJoinedUser.create(stat_joined_user)
    stat_exported_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatExportedPlan.create(stat_exported_plan)
  end

# Assign 5 question to each theme in Questions_Themes
sql = "INSERT INTO questions_themes VALUES "
sql_values = []
Theme.all.each do |theme|
  [1..5].each do
    sql_values << "(#{Question.all.sample.id} , #{theme.id})"
  end
end
sql += sql_values.join(", ")
ActiveRecord::Base.connection.insert(sql)

# Adjust org creating time
Org.all.each do |org|
  org.created_at = 6.years.ago
  org.save!
end

# Adjust templates creating time
Template.all.each_with_index do |template, index|
  template.created_at = index.month.ago
  template.save!
end
