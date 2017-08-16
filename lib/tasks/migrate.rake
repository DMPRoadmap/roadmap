namespace :migrate do
  desc "TODO"
  task permissions: :environment do
    User.update_user_permissions
  end

  desc "perform entire data migration"
  task setup: :environment do
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:schema:load'].execute
    Rake::Task['db:data:load'].execute
    Rake::Task['db:migrate'].execute
    Rake::Task['migrate:seed'].execute
    Rake::Task['migrate:permissions'].execute
  end

  desc "perform all post-migration tasks"
  task cleanup: :environment do
    Rake::Task['migrate:fix_languages'].execute
    Rake::Task['migrate:single_published_template'].execute
  end


  desc "seed database with default values for new data structures"
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
    roles.each do |role, details|
      if Role.where(name: details[:name]).empty?
        role = Role.new
        role.name = details[:name]
        role.save!
      end
    end

    # seed token permission types to database
    token_permission_types = {
        'guidances' => {
            description: "allows a user access to the guidances api endpoint"
        },
        'plans' => {
            description: "allows a user access to the plans api endpoint"
        },
        'templates' => {
            description: "allows a user access to the templates api endpoint"
        },
        'statistics' => {
            description: "allows a user access to the statistics api endpoint"
        }
    }
    token_permission_types.each do |title,settings|
      if TokenPermissionType.where(token_type: title).empty?
        token_permission_type = TokenPermissionType.new
        token_permission_type.token_type = title
        token_permission_type.text_description = settings[:description]
        token_permission_type.save!
      end
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

    languages.each do |l, details|
      if Language.where(name: details[:name]).empty?
        language = Language.new
        language.abbreviation = details[:abbreviation]
        language.description = details[:description]
        language.name = details[:name]
        language.default_language = details[:default_language]
        language.save!
      end
    end

    # seed regions to database
    regions = {
        'UK' => {
            abbreviation: 'uk',
            description: 'default region',
            name: 'UK',
        },
        'DE' => {
            abbreviation: 'de',
            description: '',
            name: 'DE',
        },
        'Horizon2020' => {
            abbreviation: 'horizon',
            description: 'European super region',
            name: 'Horizon2020',
        }
    }

    regions.each do |l, details|
      if Region.where(name: details[:name]).empty?
        region = Region.new
        region.abbreviation = details[:abbreviation]
        region.description = details[:description]
        region.name = details[:name]
        region.save!
      end
    end

  end

  desc "replaces languages in incorrect formats and seeds all correct formats"
  task fix_languages: :environment do
    languages = [
      { abbreviation: 'en_GB',
        old_abbreviation: 'en-UK',
        description: '',
        name: 'English (GB)',
        default_language: true},
      { abbreviation: 'en_US',
        old_abbreviation: 'en-US',
        description: '',
        name: 'English (US)',
        default_language: false},
      { abbreviation: 'fr',
        old_abbreviation: 'fr',
        description: '',
        name: 'Français',
        default_language: false},
      { abbreviation: 'de',
        old_abbreviation: 'de',
        description: '',
        name: 'Deutsch',
        default_language: false},
      { abbreviation: 'es',
        old_abbreviation: 'es',
        description: '',
        name: 'Español',
        default_language: false}
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

  desc "move old ORCID from user table to user_identifiers"
  task move_orcids: :environment do
    if IdentifierScheme.find_by(name: 'orcid').nil?
      IdentifierScheme.create!(name: 'orcid', description: 'ORCID', active: true)
    end

    scheme = IdentifierScheme.find_by(name: 'orcid')

    unless scheme.nil?
      User.all.each do |u|
        if u.respond_to?(:orcid_id)
          if u.orcid_id.present?
            if u.orcid_id.gsub('orcid.org/', '').match(/^[\d-]+/)
              u.user_identifiers << UserIdentifier.new(identifier_scheme: scheme,
                                                       identifier: u.orcid_id.gsub('orcid.org/', ''))
              u.save!
            end
          end
        end
      end
    end
  end

  desc "enforce single published version for templates"
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

  desc "remove duplicate annotations caused by bug"
  task remove_duplicate_annotations: :environment do
    questions = Question.joins(:annotations).group("questions.id").having("count(annotations.id) > count(DISTINCT annotations.text)")
    questions.each do |q|
      q.annotations.each do |a|
        conflicts = Annotation.where(question_id: a.question_id, text: a.text).where.not(id: a.id)
        conflicts.each {|c| c.destroy }
      end
    end
  end

end
