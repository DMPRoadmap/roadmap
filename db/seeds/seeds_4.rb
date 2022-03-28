# One super admin for the default org
  # One funder Admin for the funder organization and an Org admin and User for the institutional organization
  # -------------------------------------------------------
  # Admins are created 5 years ago
  Faker::Config.random = Random.new(60)
  pwd = ENV["USER_PASSWORD"].to_s # pwd for regular user
  users = [
    {email: "dmp.super.admin@engagedri.ca",
     firstname: "Super",
     surname: "Admin",
     language_id: 1,
     password: ENV["SUPER_ADMIN_PASSWORD"].to_s,
     password_confirmation: ENV["SUPER_ADMIN_PASSWORD"].to_s,
     org: Org.find_by(abbreviation: "Portage"),
     language: Language.all.first,
     perms: Perm.all,
     accept_terms: true,
     api_token: Org.column_defaults['api_token'],
     confirmed_at: 5.years.ago,
     created_at: 5.years.ago,
    active:1},
    {email: "dmp.test.user.admin@engagedri.ca",
     firstname: "Test",
     surname: "User",
     password: ENV["ENGLISH_ADMIN_PASSWORD"].to_s,
     password_confirmation: ENV["ENGLISH_ADMIN_PASSWORD"].to_s,
     org: Org.find_by(abbreviation: 'IEO'),
     language_id: 1, # English
     perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
     accept_terms: true,
     api_token: Org.column_defaults['api_token'],
     confirmed_at: 5.years.ago,
     created_at: 5.years.ago,
     active:1
    },
    {email: "dmp.utilisateur.test.admin@engagedri.ca",
      firstname: "Utilisateur",
      surname: "test",
      password: ENV["FRENCH_ADMIN_PASSWORD"].to_s,
      password_confirmation: ENV["FRENCH_ADMIN_PASSWORD"].to_s,
      language_id: 2, # French
      org: Org.find_by(abbreviation: 'OEO'),
      perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
      accept_terms: true,
      api_token: Org.column_defaults['api_token'],
      confirmed_at: 5.years.ago,
      created_at: 5.years.ago,
      active:1
     }
  ]
  users.each{ |u| User.create(u) }
  # Some existing users for statistics. Creation times are within 12 months
  (1..20).each do |index|
    user = {
        email: "tester" + index.to_s + "@test.ca",
        firstname: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        password: pwd,
        password_confirmation: pwd,
        org: Org.find_by(id:  ENV["FUNDER_ORG_ID"].to_i),
        language: Language.all.first,
        perms: [],
        accept_terms: true,
        api_token: Faker::Lorem.word,
        confirmed_at: rand(1...12).month.ago,
        created_at: rand(1...12).month.ago,
        active:1
    }
    User.create!(user)
  end
  (1..20).each do |index|
    user = {
        email: "tester" + (index+20).to_s + "@test.ca",
        firstname: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        password: pwd,
        password_confirmation: pwd,
        org: Org.find_by(id: ENV["ENGLISH_ORG_ID"].to_i),
        language: Language.all.first,
        perms: [],
        accept_terms: true,
        api_token: Faker::Lorem.word,
        confirmed_at: rand(1...12).month.ago,
        created_at: rand(1...12).month.ago,
        active:1
    }
    User.create!(user)
  end
  (1..20).each do |index|
    user = {
      email: "tester" + (index+40).to_s + "@test.ca",
      firstname: Faker::Name.first_name,
      surname: Faker::Name.last_name,
      password: pwd,
      password_confirmation: pwd,
      org: Org.find_by(id:ENV["FRENCH_ORG_ID"].to_i),
      language: Language.all.last, # French
      perms: [],
      accept_terms: true,
      api_token: Faker::Lorem.word,
      confirmed_at: rand(1...12).month.ago,
      created_at: rand(1...12).month.ago,
      active:1
    }
    User.create!(user)
  end
  
  # Before enter plan data, change two template's org to the two test organization to add data to user statistics
  t1 = Template.where(:title => "Portage Template").where.not(:org_id => 8).first           
  t1.org_id =  ENV["ENGLISH_ORG_ID"].to_i
  t1.title += "-Test1"
  t1.save!

  t2 = Template.where(:title => "Portage Template").where.not(:org_id => 8).first     
  t2.org_id =  ENV["FRENCH_ORG_ID"].to_i
  t2.title += "-Test2"
  t2.save!

  