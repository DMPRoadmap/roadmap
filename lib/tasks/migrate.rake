# frozen_string_literal: true

# These Tasks are for the early migrations of the codebase
namespace :migrate do
  # rubocop:disable Naming/VariableNumber
  desc 'migrate to 1.0'
  task prep_for_1_0: :environment do
    # Convert existing orgs.target_url to the orgs.links JSON arrays
    Rake::Task['migrate:org_target_url_to_links'].execute
  end
  # rubocop:enable Naming/VariableNumber

  # rubocop:disable Naming/VariableNumber
  desc 'migrate to 0.4'
  task to_04: :environment do
    # Default all plans.visibility to the value specified in application.rb
    Rake::Task['migrate:init_plan_visibility'].execute
    # Move old plans.data_contact to plans.data_contact_email if value is an email
    Rake::Task['migrate:plan_data_contacts'].execute
    # Move users.orcid_id to the user_identifiers table
    Rake::Task['migrate:move_orcids'].execute
    # Move users.shibboleth_id to the user_identifiers table
    Rake::Task['migrate:move_shibs'].execute
  end
  # rubocop:enable Naming/VariableNumber

  desc 'TODO'
  task permissions: :environment do
    User.update_user_permissions
  end

  desc 'perform entire data migration'
  task setup: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:schema:load'].execute
    Rake::Task['db:data:load'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['migrate:seed'].execute
    Rake::Task['migrate:permissions'].execute
  end

  desc 'perform all post-migration tasks'
  task cleanup: :environment do
    Rake::Task['migrate:fix_languages'].execute
    Rake::Task['migrate:single_published_template'].execute
  end

  desc 'seed database with default values for new data structures'
  task seed: :environment do
    # seed roles to database
    roles = {
      'add_organisations' => {
        name: 'add_organisations'
      },
      'change_org_affiliation' => {
        name: 'change_org_affiliation'
      },
      'grant_permissions' => {
        name: 'grant_permissions'
      },
      'modify_templates' => {
        name: 'modify_templates'
      },
      'modify_guidance' => {
        name: 'modify_guidance'
      },
      'use_api' => {
        name: 'use_api'
      },
      'change_org_details' => {
        name: 'change_org_details'
      },
      'grant_api_to_orgs' => {
        name: 'grant_api_to_orgs'
      }
    }
    roles.each_value do |details|
      next unless Role.where(name: details[:name]).empty?

      role = Role.new
      role.name = details[:name]
      role.save!
    end

    # seed token permission types to database
    token_permission_types = {
      'guidances' => {
        description: 'allows a user access to the guidances api endpoint'
      },
      'plans' => {
        description: 'allows a user access to the plans api endpoint'
      },
      'templates' => {
        description: 'allows a user access to the templates api endpoint'
      },
      'statistics' => {
        description: 'allows a user access to the statistics api endpoint'
      }
    }
    token_permission_types.each do |title, settings|
      next unless TokenPermissionType.where(token_type: title).empty?

      token_permission_type = TokenPermissionType.new
      token_permission_type.token_type = title
      token_permission_type.text_description = settings[:description]
      token_permission_type.save!
    end

    # seed languages to database
    languages = {
      'English(GB)' => {
        abbreviation: 'en_GB',
        description: '',
        name: 'English (GB)',
        default_language: true
      },
      'English(US)' => {
        abbreviation: 'en_US',
        description: '',
        name: 'English (US)',
        default_language: false
      },
      'FR' => {
        abbreviation: 'fr',
        description: '',
        name: 'Français',
        default_language: false
      },
      'DE' => {
        abbreviation: 'de',
        description: '',
        name: 'Deutsch',
        default_language: false
      },
      'Español' => {
        abbreviation: 'es',
        description: '',
        name: 'Español',
        default_language: false
      }
    }

    languages.each_value do |details|
      next unless Language.where(name: details[:name]).empty?

      language = Language.new
      language.abbreviation = details[:abbreviation]
      language.description = details[:description]
      language.name = details[:name]
      language.default_language = details[:default_language]
      language.save!
    end

    # seed regions to database
    regions = {
      'UK' => {
        abbreviation: 'uk',
        description: 'default region',
        name: 'UK'
      },
      'DE' => {
        abbreviation: 'de',
        description: '',
        name: 'DE'
      },
      'Horizon2020' => {
        abbreviation: 'horizon',
        description: 'European super region',
        name: 'Horizon2020'
      }
    }

    regions.each_value do |details|
      next unless Region.where(name: details[:name]).empty?

      region = Region.new
      region.abbreviation = details[:abbreviation]
      region.description = details[:description]
      region.name = details[:name]
      region.save!
    end
  end

  desc 'replaces languages in incorrect formats and seeds all correct formats'
  task fix_languages: :environment do
    languages = [
      { abbreviation: 'en_GB',
        old_abbreviation: 'en-UK',
        description: '',
        name: 'English (GB)',
        default_language: true },
      { abbreviation: 'en_US',
        old_abbreviation: 'en-US',
        description: '',
        name: 'English (US)',
        default_language: false },
      { abbreviation: 'fr',
        old_abbreviation: 'fr',
        description: '',
        name: 'Français',
        default_language: false },
      { abbreviation: 'de',
        old_abbreviation: 'de',
        description: '',
        name: 'Deutsch',
        default_language: false },
      { abbreviation: 'es',
        old_abbreviation: 'es',
        description: '',
        name: 'Español',
        default_language: false }
    ]

    languages.each do |lang_data|
      # if the old abbreviation exists, remove and replace the data
      lang = Language.find_by(abbreviation: lang_data[:old_abbreviation])
      if lang.present?
        lang.abbreviation = lang_data[:abbreviation]
        lang.description = lang_data[:description]
        lang.name = lang_data[:name]
        lang.default_language = lang_data[:default_language]
        lang.save!
      else
        # if nothing batching either abbreviation exists, replace with new abbreviation
        lang = Language.find_by(abbreviation: lang_data[:abbreviation])
        if lang.blank?
          lang = Language.new
          lang.abbreviation = lang_data[:abbreviation]
          lang.description = lang_data[:description]
          lang.name = lang_data[:name]
          lang.default_language = lang_data[:default_language]
          lang.save!
        end
      end
    end
  end

  desc 'enforce single published version for templates'
  task single_published_template: :environment do
    # for each group of versions of a template
    Template.all.pluck(:dmptemplate_id).uniq.each do |dmptemplate_id|
      published = false
      Template.where(dmptemplate_id: dmptemplate_id).order(version: :desc).each do |template|
        # leave the first published template we find alone
        if !published && template.published
          published = true
        elsif published && template.published
          template.published = false
          template.save!
        end
      end
    end
  end

  # Tasks required to migrate to 0.4.x
  # -----------------------------------------------
  desc 'Initialize plans.visibility to the default specified in application.rb'
  task init_plan_visibility: :environment do
    default = Rails.configuration.x.plans.default_visibility.to_sym
    Plan.all.each { |p| p.update(visibility: default) unless p.visibility == default }
  end

  desc 'Move old plans.data_contact to data_contact_email and data_contact_phone'
  task plan_data_contacts: :environment do
    email_regex = /([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})/i
    phone_regex = /\+?[0-9\-()]{7,}/i
    Plan.where('data_contact IS NOT NULL').each do |p|
      email = p.data_contact[email_regex]
      phone = p.data_contact[phone_regex]

      # Remove the email, phone and any prefixes from the oriignal contact
      contact = p.data_contact
      contact = contact.gsub(email, '') unless email.nil?
      contact = contact.gsub(phone, '') unless phone.nil?
      contact = contact.gsub(/([Ee]mail|[Pp]hone|[Mm]obile|[Cc]ell|[Oo]ffice|[Hh]ome|[Ww]ork|[Tt]|[Ee]):?/, '')
      contact = contact.gsub(' , ', '').strip
      contact = contact[0..(contact.length - 2)] if contact.ends_with?(',')
      contact = nil if contact == ','

      p.update(data_contact_email: email, data_contact_phone: phone, data_contact: contact)
    end
  end

  desc 'Move old ORCID from users table to user_identifiers'
  task move_orcids: :environment do
    users = User.includes(:user_identifiers).where('users.orcid_id IS NOT NULL')

    # If we have users with orcid ids
    if users.any?
      # If orcid isn't defined in the identifier_schemes table add it
      if IdentifierScheme.find_by(name: 'orcid').nil?
        IdentifierScheme.create!(name: 'orcid',
                                 description: 'ORCID',
                                 active: true,
                                 logo_url: 'http://orcid.org/sites/default/files/images/orcid_16x16.png',
                                 user_landing_url: 'https://orcid.org')
      end

      scheme = IdentifierScheme.find_by(name: 'orcid')

      unless scheme.nil?
        users.each do |u|
          next unless u.orcid_id.gsub('orcid.org/', '').match?(/^[\d-]+/)

          schemes = u.user_identifiers.collect(&:identifier_scheme_id)

          unless schemes.include?(scheme.id)
            UserIdentifier.create(user: u, identifier_scheme: scheme,
                                  identifier: u.orcid_id.gsub('orcid.org/', ''))
          end
        end
      end
    end
  end

  desc 'Move old Shibboleth Ids from users table to user_identifiers'
  task move_shibs: :environment do
    if Rails.configuration.x.shibboleth.enabled
      users = User.includes(:user_identifiers).where('users.shibboleth_id IS NOT NULL')

      # If we have users with orcid ids
      if users.any?
        # If orcid isn't defined in the identifier_schemes table add it
        if IdentifierScheme.find_by(name: 'shibboleth').nil?
          IdentifierScheme.create!(name: 'shibboleth',
                                   description: 'Your institution credentials',
                                   active: true)
        end

        scheme = IdentifierScheme.find_by(name: 'shibboleth')

        unless scheme.nil?
          users.each do |u|
            schemes = u.user_identifiers.collect(&:identifier_scheme_id)

            next if schemes.include?(scheme.id)
            # TODO: Add logic to move shib identifiers over
            #              UserIdentifier.create(user: u, identifier_scheme: scheme,
            #                                    identifier: u.orcid_id.gsub('orcid.org/', ''))
          end
        end
      end
    end
  end

  desc 'remove duplicate annotations caused by bug'
  task remove_duplicate_annotations: :environment do
    questions = Question.joins(:annotations)
                        .group('questions.id')
                        .having('count(annotations.id) > count(DISTINCT annotations.text)')
    questions.each do |q|
      # store already de-duplicated id's so we dont remove them in later iterations
      removed = []
      q.annotations.each do |a|
        removed << a.id
        conflicts = Annotation.where(question_id: a.question_id, text: a.text).where.not(id: removed)
        conflicts.each(&:destroy)
      end
    end
  end

  desc 'convert orgs.target_url to JSON array'
  task org_target_url_to_links: :environment do
    Org.all.each do |org|
      next unless org.target_url.present?

      org.links = [{ link: org.target_url, text: '' }]
      org.target_url = nil

      # Running with validations off because Dragonfly will fail if it cannot find the
      # org logos which live on the deployed instance
      org.save!(validate: false)
    end
  end
end
