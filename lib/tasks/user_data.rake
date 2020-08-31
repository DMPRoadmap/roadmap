namespace :db do
  desc "Fill database with sample data"
  task populate: :environments do
    admin = User.create!(email: "test@test.com",
                 password: "password",
                 password_confirmation: "password")
    admin.add_role(:admin)
  end

  desc "Delete User entries with emails with no MX DNS record"
  task delete_users_no_email_mx: :environment do

    Truemail.configure do |config|
      config.verifier_email = 'tesr@ualberta.com'
    end

    user_total = User.count
    
    
    log_user = lambda do |index, user_total, user_email = nil|
      user_total_string_length = user_total.to_s.length
      message = "#{index.to_s.rjust(user_total_string_length, " ")}/#{user_total}"
      message += " : #{user_email}" unless user_email.nil?

      puts message
    end

    puts "Starting..."
    log_user.call(0, user_total)
    User.all.entries.each_with_index  do |user, idx|
      email_validator = Truemail.validate(user[:email], with: :mx)
      unless email_validator.result.success #do
        begin
          log_user.call(idx, user_total, user[:email])
          user.destroy
        rescue
          puts "Problem deleting user #{user[:email]}"
        end
      end
    end
    puts "Done!"
  end
end