namespace :dmptool_stats do

  desc "Get number of users per identifier scheme"
  task :nbr_users_per_identifier_scheme => :environment do
    p "Gathering user counts for each Identifier Scheme"
    users = User.all.where(active: true)
    hash = { total_users: users.length }
    IdentifierScheme.all.each do |is|
      hash["with_#{is.name}".to_sym] = UserIdentifier.joins(:user).where(identifier_scheme: is).length
    end
    hash[:with_no_identifiers] = User.includes(:user_identifiers).where('user_identifiers.user_id': nil).length
    file = to_file(hash, "nbr-users-per-identifier-scheme")
    p "Done ... file written to: #{file}"
  end

  desc "Get number of plans per institution"
  task :nbr_plans_per_institution => :environment do
    p "Gathering plan counts (by funder) for each Institution"
    funder_templates = {}
    Org.where(org_type: 2).order(:abbreviation).each do |funder|
      funder_templates[funder.abbreviation.to_sym] = Template.joins(:org)
              .where("templates.published = ? and orgs.id = ?", true, funder.id)
              .pluck(:family_id)
    end

    hash = {}
    Org.includes(users: { plans: :template }).all.order(:name).each do |org|
      counts = {}
      users = org.users.pluck(:id).uniq

      funder_templates.each do |k, v|
        plans = Plan.joins(:template, :roles)
                    .where("roles.access = ? and \
                            roles.user_id in (?) and \
                            (templates.family_id in (?) or customization_of in (?))",
                            15, users, v, v).pluck(:id).uniq
                    .length
        counts[k] = plans if plans > 0
      end
      hash[org.name] = counts
    end

    file = to_file(hash, "nbr-plans-per-institution")
    p "Done ... file written to: #{file}"
  end

  private

  def to_file(hash, filename)
    now = Date.today
    filename = "#{filename}_#{now.year}_#{now.month}_#{now.day}.json"
    File.write(Rails.root.join("tmp", filename), JSON.pretty_generate(hash))
    "tmp/#{filename}"
  end

end
