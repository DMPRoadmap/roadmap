namespace :db do
  desc "Fill database with sample data"
  task populate: :environments do
    admin = User.create!(email: "test@test.com",
                 password: "password",
                 password_confirmation: "password")
    admin.add_role(:admin)
  end
end