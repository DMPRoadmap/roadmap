
  require 'faker'
  # One super admin for the default org
  # One funder Admin for the funder organization and an Org admin and User for the institutional organization
  # -------------------------------------------------------
  # Admins are created 5 years ago
  users = [
    {email: "dmp.super.admin@engagedri.ca",
     firstname: "Super",
     surname: "Admin",
     password: "@YX(rg_<)9<eeLL+",
     password_confirmation: "@YX(rg_<)9<eeLL+",
     org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
     language: Language.all.first,
     perms: Perm.all,
     accept_terms: true,
     api_token: 'KQYyAdy6kGUrFGKu',
     confirmed_at: 5.years.ago,
     created_at: 5.years.ago,
    active:1},
    {email: "dmp.insitution.admin@engagedri.ca",
     firstname: "Institution",
     surname: "Admin",
     password: "Sqg+GKpx7qxc^Gb5",
     password_confirmation: "Sqg+GKpx7qxc^Gb5",
     org: Org.find_by(abbreviation: 'IEO'),
     language: Language.all.first,
     perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
     accept_terms: true,
     api_token: 'n0Ov0i68VRxc4yRv',
     confirmed_at: 5.years.ago,
     created_at: 5.years.ago,
     active:1
    },
    {email: "dmp.organisation.admin@engagedri.ca",
      firstname: "Organisation",
      surname: "Admin",
      password: "dW}W5~QR",
      password_confirmation: "dW}W5~QR",
      org: Org.find_by(abbreviation: 'OEO'),
      language: Language.all.first,
      perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
      accept_terms: true,
      api_token: 'n0Ov0i68VRxc4yRv',
      confirmed_at: 5.years.ago,
      created_at: 5.years.ago,
      active:1
     }
  ]
  users.each{ |u| User.create(u) }
  # Some existing users for statistics. Creation times are within 12 months
  (1..20).each do |index|
    pwd = Faker::Lorem.unique
    user = {
        email: Faker::Internet.email,
        firstname: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        password: pwd,
        password_confirmation: pwd,
        org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
        language: Language.all.first,
        perms: [],
        accept_terms: true,
        api_token: Faker::Lorem.word,
        confirmed_at: 2.month.ago,
        created_at: 2.month.ago,
        active:1
    }
    User.create(user)
  end
  (1..20).each do |index|
    pwd = Faker::Lorem.unique
    user = {
        email: Faker::Internet.email,
        firstname: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        password: pwd,
        password_confirmation: pwd,
        org: Org.find_by(abbreviation: 'OEO'),
        language: Language.all.first,
        perms: [],
        accept_terms: true,
        api_token: Faker::Lorem.word,
        confirmed_at: 3.month.ago,
        created_at: 3.month.ago,
        active:1
    }
    User.create(user)
  end
  (1..20).each do |index|
    pwd = Faker::Lorem.unique
    user = {
      email: Faker::Internet.email,
      firstname: Faker::Name.first_name,
      surname: Faker::Name.last_name,
      password: pwd,
      password_confirmation: pwd,
      org: Org.find_by(abbreviation: 'IEO'),
      language: Language.all.first,
      perms: [],
      accept_terms: true,
      api_token: Faker::Lorem.word,
      confirmed_at: 4.month.ago,
      created_at: 4.month.ago,
      active:1
    }
    User.create(user)
  end
  
  