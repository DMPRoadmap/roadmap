# frozen_string_literal: true

namespace :usercleaning do
  desc 'Remove users who haven\'t accepted invitation after 1 month.'
  task non_accepted_invitations: :environment do
    Rails.logger.info 'Deleting user uncomfirmed users invited over a month ago'
    User
      .where('invitation_sent_at < ? AND invitation_accepted_at IS NULL AND last_sign_in_at IS NULL', 1.month.ago)
      .each do |user|
      p "#{user.email}  deleted"
      user.destroy
    end
  end

  # rubocop:disable Lint/DuplicateBranch
  desc 'Anonymize users who haven\'t been connected for five years.'
  task anonymize_users_after_5_years: :environment do
    Rails.logger.info 'Anonymizing users who have not connected for the last 5 years'

    User.where('active = true and last_sign_in_at < ?', 5.years.ago - 1.month).each do |user|
      case user.last_sign_in_at.to_date
      when (5.years.ago - 1.month).to_date
        UserMailer.anonymization_warning(user).deliver_now
      when (5.years.ago - 1.week).to_date
        UserMailer.anonymization_warning(user).deliver_now
      when (5.years.ago - 1.day).to_date
        UserMailer.anonymization_warning(user).deliver_now
      else user.archive # default should archive every other user : last log in > 5y
      end
    end
  end
  # rubocop:enable Lint/DuplicateBranch
end
