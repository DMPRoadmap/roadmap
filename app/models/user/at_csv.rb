# frozen_string_literal: true

class User

  class AtCsv

    HEADERS = ["Name", "E-Mail", "Created Date", "Last Activity", "Plans",
               "Current Privileges", "Active", "Department"].freeze

    def initialize(users)
      @users = users
    end

    def to_csv
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        @users.each do |user|
          name = "#{user.firstname} #{user.surname}"
          email = user.email
          created = I18n.l user.created_at.to_date, format: :csv
          last_activity = I18n.l user.updated_at.to_date, format: :csv
          plans = user.plans.size
          active = user.active ? "Yes" : "No"

          current_privileges = if user.can_super_admin?
                                 "Super Admin"
                               elsif user.can_org_admin?
                                 "Organisational Admin"
                               else
                                 ""
                               end

          department = user&.department&.name || ""

          csv << [name, email, created, last_activity, plans, current_privileges,
                  active, department]
        end
      end
    end

  end

end
