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
  template.created_at = rand(1...12).month.ago
  template.save!
end

# Adjust plan and role creation date for statistics
Plan.all.each do |plan|
  plan.created_at = rand(1...12).month.ago
  plan.save!
end
Role.all.each do |role|
  role.created_at = rand(1...12).month.ago
  role.save!
end