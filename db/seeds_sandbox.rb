#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true

# This file serves for the sandbox testing after 3.0 release

# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
# Languages (check config/locales for any ones not defined here)
# -------------------------------------------------------

require 'faker'

languages = [
  {abbreviation: 'en-CA',
   description: '',
   name: 'English (CA)',
   default_language: true},
  {abbreviation: 'fr-CA',
   description: '',
   name: 'Français (CA)',
   default_language: false}
]
  languages.each { |l| Language.create!(l) }
  
  default_locale = LocaleService.to_i18n(locale: LocaleService.default_locale).to_s
  default_language = Language.find_by(abbreviation: default_locale)
  
  # When this is executed by `db:setup`, the translation initializer did not run
  # so we need to establish the I18n locales manually
  I18n.available_locales = LocaleService.available_locales.map do |locale|
    LocaleService.to_i18n(locale: locale)
  end
  I18n.available_locales << :en unless I18n.available_locales.include?(:en)
  I18n.default_locale = default_locale
  
  # Identifier Schemes
  # -------------------------------------------------------
  identifier_schemes = [
    {
      name: 'orcid',
      description: 'ORCID',
      active: true,
      logo_url:'http://orcid.org/sites/default/files/images/orcid_16x16.png',
      identifier_prefix:'https://orcid.org'
    },
    {
      name: 'shibboleth',
      description: 'Your institutional credentials',
      active: true,
      logo_url: 'http://newsite.shibboleth.net/wp-content/uploads/2017/01/Shibboleth-logo_2000x1200-1.png',
      identifier_prefix: "https://example.com"
    },
  ]
  identifier_schemes.each { |is| IdentifierScheme.create!(is) }
  
  # Question Formats
  # -------------------------------------------------------
  question_formats = [
    {
      title: "Text area",
      description: "A Tinymce text area",
      option_based: false,
      formattype: 0
    },
    {
      title: "Text field",
      description: "A standard HTML text field",
      option_based: false,
      formattype: 1
    },
    {
      title: "Radio buttons",
      description: "A standard set of HTML radio button fields",
      option_based: true,
      formattype: 2
    },
    {
      title: "Check box",
      description: "A standard set of HTML checkbox fields",
      option_based: true,
      formattype: 3
    },
    {
      title: "Dropdown",
      description: "A standard HTML select field",
      option_based: true,
      formattype: 4
    },
    {
      title: "Multi select box",
      description: "A standard HTML multi-select field",
      option_based: true,
      formattype: 5
    },
    {
      title: "Date",
      description: "A standard HTML5 date field",
      option_based: false,
      formattype: 6
    }
  ]
  question_formats.each{ |qf| QuestionFormat.create!(qf) }
  
  # # Scan through the locale files and add an entry if a file is present but
  # # not defined in this seed file
  # Dir.entries("#{Rails.root.join("config", "locales").to_s}").each do |f|
  #   if f[-4..-1] == '.yml'
  #     lang = f.gsub('.yml', '')
  #
  #     if Language.where(abbreviation: lang).empty?
  #       Language.create!({
  #         abbreviation: lang,
  #         description: lang,
  #         name: lang,
  #         default_language: false
  #       })
  #     end
  #   end
  # end
  
  # Regions (create the super regions first and then create the rest)
  # -------------------------------------------------------
  regions = [
    {abbreviation: 'ca',
      description: 'Canada',
      name: 'CA'},
    {abbreviation: 'horizon',
     description: 'European super region',
     name: 'Horizon2020',
      sub_regions: [
        {abbreviation: 'uk',
          description: 'United Kingdom',
          name: 'UK'},
        {abbreviation: 'de',
          description: 'Germany',
          name: 'DE'},
        {abbreviation: 'fr',
          description: 'France',
          name: 'FR'},
        {abbreviation: 'es',
          description: 'Spain',
          name: 'ES'}
    ]},
    {abbreviation: 'us',
     description: 'United States of America',
     name: 'US'}
  ]
  
  # Create the region. If it has subregions create them and then connect them
  regions.each do |r|
    srs = r[:sub_regions]
    r.delete(:sub_regions) unless r[:sub_regions].nil?
  
    if Region.find_by(abbreviation: r[:abbreviation]).nil?
      region = Region.create!(r)
  
      unless srs.nil?
        srs.each do |sr|
          if Region.find_by(abbreviation: sr[:abbreviation]).nil?
            sr[:super_region] = region
            Region.create!((sr))
          end
        end
      end
  
    end
  end
  
  # Perms
  # -------------------------------------------------------
  perms = [
    {name: 'add_organisations'},
    {name: 'change_org_affiliation'},
    {name: 'grant_permissions'},
    {name: 'modify_templates'},
    {name: 'modify_guidance'},
    {name: 'use_api'},
    {name: 'change_org_details'},
    {name: 'grant_api_to_orgs'},
    {name: 'review_org_plans'}
  ]
  perms.each{ |p| Perm.create!(p) }
  
  # Guidance Themes
  # -------------------------------------------------------
  themes = [
    {title: 'Data Description'},
    {title: 'Data Format'},
    {title: 'Data Volume'},
    {title: 'Data Collection'},
    {title: 'Metadata & Documentation'},
    {title: 'Ethics & Privacy'},
    {title: 'Intellectual Property Rights'},
    {title: 'Storage & Security'},
    {title: 'Data Sharing'},
    {title: 'Data Repository'},
    {title: 'Preservation'},
    {title: 'Roles & Responsibilities'},
    {title: 'Budget'},
    {title: 'Related Policies'}
  ]
  themes.each { |t| Theme.create!(t.merge(locale: default_locale)) }
  
  # Token Permission Types
  # -------------------------------------------------------
  token_permission_types = [
    {token_type: 'guidances', text_description: 'allows a user access to the guidances api endpoint'},
    {token_type: 'plans', text_description: 'allows a user access to the plans api endpoint'},
    {token_type: 'templates', text_description: 'allows a user access to the templates api endpoint'},
    {token_type: 'statistics', text_description: 'allows a user access to the statistics api endpoint'}
  ]
  token_permission_types.each{ |tpt| TokenPermissionType.create!(tpt) }
  
  # 5 Typical Organizations. One for Each Kind
  # All orgs are created 6 years ago
  # -------------------------------------------------------
  region = Region.first
  # Super admin uses the default organizational (Alliance)
  orgs = [
    {name: Rails.configuration.x.organisation.name,
     abbreviation: Rails.configuration.x.organisation.abbreviation,
     org_type: 4, links: {"org":[]}, #research_institute
     language: default_language, region: region,
     token_permission_types: TokenPermissionType.all,
     is_other: true, managed: true,
     created_at: 6.year.ago
    },
    {name: 'Institution Example Org',
     abbreviation: 'IEO',
     org_type: 1, links: {"org":[]}, #institution
     language: default_language, region: region,
     is_other: false, managed: true,
     created_at: 6.year.ago},
    {name: 'Organization Example Org',
    abbreviation: 'OEO',
    org_type: 3, links: {"org":[]}, #organisation
    language: default_language, region: region,
    is_other: false, managed: true,
    created_at: 6.year.ago},
    {name: 'Project Example Org',
      abbreviation: 'PEO',
      org_type: 5, links: {"org":[]}, #project
      language: default_language, region: region,
      is_other: false, managed: true,
      created_at: 6.year.ago},
    {name: 'School Example Org',
      abbreviation: 'SEO',
      org_type: 6, links: {"org":[]}, #school
      language: default_language, region: region,
      is_other: false, managed: true,
      created_at: 6.year.ago},
    {name: 'Funder Example Org',
      abbreviation: 'FEO',
      org_type: 2, links: {"org":[]}, #funder
      language: default_language, region: region,
      is_other: false, managed: true,
      created_at: 6.year.ago}
  ]
  orgs.each { |o| Org.create!(o) }
  # Create other random orgs for test
  (1..5).each do |index|
      org = {
          name: Faker::University.name,
          abbreviation: Faker::Lorem.word + index.to_s,
          org_type: 4,
          links: {"org":[]},
          language: default_language,
          region: region,
          is_other: false,
          managed: true,
          created_at: 6.year.ago
          }
      Org.create(org)
    end
    (1..5).each do |index|
      index = index+100
      org = {
          name: Faker::University.name,
          abbreviation: Faker::Lorem.word + index.to_s,
          org_type: 6,
          links: {"org":[]},
          language: default_language,
          region: region,
          is_other: false,
          managed: true,
          created_at: 6.year.ago
      }
      Org.create(org)
    end 
    (1..5).each do |index|
      index = index+200
      org = {
        name: Faker::University.name,
        abbreviation: Faker::Lorem.word  + index.to_s,
        org_type: index-200,
        links: {"org":[]},
        language: default_language,
        region: region,
        is_other: false,
        managed: true,
        created_at: 6.year.ago
      }
      Org.create(org)    
    end
  
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
     language: default_language,
     perms: Perm.all,
     accept_terms: true,
     api_token: 'KQYyAdy6kGUrFGKu',
     confirmed_at: 5.years.ago,
     created_at: 5.years.ago,
    active:1},
    {email: "dmp.insitution.admin@engagedri.ca",
     firstname: "Insitution",
     surname: "Admin",
     password: "Sqg+GKpx7qxc^Gb5",
     password_confirmation: "Sqg+GKpx7qxc^Gb5",
     org: Org.find_by(abbreviation: 'IEO'),
     language: default_language,
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
      language: default_language,
      perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
      accept_terms: true,
      api_token: 'n0Ov0i68VRxc4yRv',
      confirmed_at: 5.years.ago,
      created_at: 5.years.ago,
      active:1
     },
    # For funder, school and project admin, the user account could be created when needed. 
    # For sandbox test, using the three accounts above
    #  {email: "dmp.funder.admin@engagedri.ca",
    #   firstname: "Funder",
    #   surname: "Admin",
    #   password: "N9xGbbNmJza?D3pW",
    #   password_confirmation: "N9xGbbNmJza?D3pW",
    #   org: Org.find_by(abbreviation: 'FEO'),
    #   language: default_language,
    #   perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
    #   accept_terms: true,
    #   api_token: 'apn9rmLYOyfN3kPz',
    #   confirmed_at: 5.years.ago,
    #   created_at: 5.years.ago,
    #   active:1},
  ]
  users.each{ |u| User.create(u) }
  # Some existing users for statisitics. Creation times are within 12 months
  (1..50).each do |index|
    pwd = Faker::Lorem.unique
    user = {
        email: Faker::Internet.email,
        firstname: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        password: pwd,
        password_confirmation: pwd,
        org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
        language: default_language,
        perms: [],
        accept_terms: true,
        api_token: Faker::Lorem.word,
        confirmed_at: 2.month.ago,
        created_at: 2.month.ago,
        active:1
    }
    User.create(user)
  end
  (1..50).each do |index|
    pwd = Faker::Lorem.unique
    user = {
        email: Faker::Internet.email,
        firstname: Faker::Name.first_name,
        surname: Faker::Name.last_name,
        password: pwd,
        password_confirmation: pwd,
        org: Org.find_by(abbreviation: 'OEO'),
        language: default_language,
        perms: [],
        accept_terms: true,
        api_token: Faker::Lorem.word,
        confirmed_at: 3.month.ago,
        created_at: 3.month.ago,
        active:1
    }
    User.create(user)
  end
  (1..50).each do |index|
    pwd = Faker::Lorem.unique
    user = {
      email: Faker::Internet.email,
      firstname: Faker::Name.first_name,
      surname: Faker::Name.last_name,
      password: pwd,
      password_confirmation: pwd,
      org: Org.find_by(abbreviation: 'IEO'),
      language: default_language,
      perms: [],
      accept_terms: true,
      api_token: Faker::Lorem.word,
      confirmed_at: 4.month.ago,
      created_at: 4.month.ago,
      active:1
    }
    User.create(user)
  end


  # Guidance Groups for the default org, funder admin's org and institution admin's org
  # Guidance Groups are created 4 years ago
  # -------------------------------------------------------
  guidance_groups = [
    {name: "Generic Guidance (provided by the example curation centre)",
     org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
     optional_subset: true,
     published: true,
     created_at: 4.years.ago},
    {name: "Government Agency Advice (Organisation specific guidance)",
     org: Org.find_by(abbreviation: 'OEO'),
     optional_subset: false,
     published: true,
     created_at: 4.years.ago},
    {name: "Institution Advice (Institution specific guidance)",
    org: Org.find_by(abbreviation: 'IEO'),
    optional_subset: false,
    published: true,
    created_at: 4.years.ago}
  ]
  guidance_groups.each do |gg|
    guidance_group = GuidanceGroup.find_or_create_by(org: gg[:org])
    guidance_group.update!(gg)
  end
  # 5 test random guiance group
  (1..5).each do |index|
      gg = {
          name: Faker::Lorem.word,
          org: Org.all.sample,
          optional_subset: true,
          published: true,
          created_at: 4.years.ago
      }
      guiance_group = GuidanceGroup.find_or_create_by(org: gg[:org])
      guiance_group.update!(gg)
  end
  
  # Guidances for random guidance group using random theme
  # -------------------------------------------------------
  (1..50).each do |index|
    guidance = 
      { text: Faker::Lorem.word,
        guidance_group: GuidanceGroup.all.sample,
        published: true,
        themes:  [Theme.all.sample],
        created_at: 4.years.ago
      }
    Guidance.create(guidance)
    end

  # Three standard templates for default org, funder admin's org and insitutional admin's org
  # Templates are created 3 years ago
  # -------------------------------------------------------
  templates = [
    {title: "Sample Template - Super Admin's Org",
     description: "The default template",
     published: true,
     org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
     is_default: true, locale: default_locale,
     version: 1,
     family_id: 1,
     visibility: Template.visibilities[:publicly_visible],
     links: {"funder":[],"sample_plan":[]},
     created_at: 3.years.ago,
     updated_at: 3.years.ago
    },
    {title: "Sample Template - Institutional Admin's Org",
     published: true,
     org: Org.find_by(abbreviation: 'IEO'),
     is_default: true, locale: default_locale,
     version: 1,
     family_id: 2,
     visibility: Template.visibilities[:organisationally_visible],
     links: {"funder":[],"sample_plan":[]},
     created_at: 3.years.ago,
     updated_at: 3.years.ago
    },
    {title: "Sample Template - Organisational Admin's Org",
      published: true,
      org: Org.find_by(abbreviation: 'OEO'),
      is_default: true, locale: default_locale,
      version: 1,
      family_id: 3,
      visibility: Template.visibilities[:organisationally_visible],
      links: {"funder":[],"sample_plan":[]},
      created_at: 3.years.ago,
      updated_at: 3.years.ago
     }
  ]
  # Template creation calls defaults handler which sets is_default and
  # published to false automatically, so update them after creation
  templates.each { |atts| Template.create!(atts) }
  # More template for admin to test
  (1..10).each do |index|
  template = {
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.sentence,
      published: true,
      org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
      is_default: false, 
      locale: default_locale,
      version: index+10,
      visibility: 0,
      family_id: index+10,
      links: {"funder":[],"sample_plan":[]},
      created_at: 3.years.ago,
      updated_at: 2.years.ago
    }
  Template.create!(template)
  end
  (1..10).each do |index|
      template = {
          title: Faker::Lorem.sentence,
          description: Faker::Lorem.sentence,
          published: true,
          org: Org.find_by(abbreviation: "OEO"),
          is_default: false, 
          locale: default_locale,
          version: index+20,
          family_id: index+20,
          visibility: 0,
          links: {"funder":[],"sample_plan":[]},
          created_at: 3.years.ago,
          updated_at: 2.years.ago
        }
      Template.create!(template)
  end
  (1..10).each do |index|
      template = {
          title: Faker::Lorem.sentence,
          description: Faker::Lorem.sentence,
          published: true,
          org: Org.find_by(abbreviation: "IEO"),
          is_default: false, 
          locale: default_locale,
          version: index+30,
          family_id: index+30,
          visibility: 0,
          links: {"funder":[],"sample_plan":[]},
          created_at: 3.years.ago,
          updated_at: 2.years.ago
        }
      Template.create!(template)
  end
  (1..10).each do |index|
      template = {
          title: Faker::Lorem.sentence,
          description: Faker::Lorem.sentence,
          published: true,
          org: Org.all.sample,
          is_default: false, 
          locale: default_locale,
          version: index+40,
          family_id: index+40,
          visibility: 0,
          links: {"funder":[],"sample_plan":[]},
          created_at: 3.years.ago,
          updated_at: 2.years.ago
        }
      Template.create!(template)
  end
    

  # Test phases for templates. Created 2 years ago
  # 1 phase for super admin's template
  # 2 phases for the funder admin's template
  # 3 phases for the org admin's template
  # -------------------------------------------------------
  phases = [
    {title: "A Common Phase",
     number: 1,
     modifiable: false,
     template: Template.find_by(title: "Sample Template - Super Admin's Org"),
     created_at: 2.years.ago,
    },
    {title: "Phase 1 of Organisational Admin's Sample Template",
      number: 1,
      modifiable: false,
      template: Template.find_by(title: "Sample Template - Organisational Admin's Org"),
      created_at: 2.years.ago
     },
    {title: "Phase 2 of Organisational Admin's Sample Template",
    number: 2,
    modifiable: false,
    template: Template.find_by(title: "Sample Template - Organisational Admin's Org"),
    created_at: 2.years.ago
   },
    {title: "Phase 1 of Institutional Admin's Sample Template",
     number: 1,
     modifiable: true,
     template: Template.find_by(title: "Sample Template - Institutional Admin's Org"),
     created_at: 3.years.ago
    },
    {title: "Phase 2 of Institutional Admin's Sample Template",
     number: 2,
     modifiable: false,
     template: Template.find_by(title: "Sample Template - Institutional Admin's Org"),
     created_at: 3.years.ago
    },
    {title: "A Common Phase",
    number: 3,
    modifiable: false,
    template: Template.find_by(title: "Sample Template - Institutional Admin's Org"),
    created_at: 3.years.ago
    }
  ]
  phases.each{ |p| Phase.create!(p) }
  
  generic_template_phase_1 = Phase.find_by(title: "A Common Phase")
  org_template_phase_1  = Phase.find_by(title: "Phase 1 of Organisational Admin's Sample Template")
  org_template_phase_2  = Phase.find_by(title: "Phase 2 of Organisational Admin's Sample Template")
  insitution_template_phase_1  = Phase.find_by(title: "Phase 1 of Institutional Admin's Sample Template")
  insitution_template_phase_2  = Phase.find_by(title: "Phase 2 of Institutional Admin's Sample Template")

  # Create sections for the templates and their phases
  # -------------------------------------------------------
  sections = [
    {title: "Test Section 1",
     number: 1,
     modifiable: false,
     phase: generic_template_phase_1,
     created_at: 2.years.ago
    },
    {title: "Test Section 2",
     number: 2,
     modifiable: false,
     phase: org_template_phase_1,
     created_at: 2.years.ago
    },
    {title: "Test Section 3",
     number: 3,
     modifiable: false,
     phase: org_template_phase_2,
     created_at: 2.years.ago
    },
    {title: "Test Section 4",
     number: 4,
     modifiable: false,
     phase: insitution_template_phase_1,
     created_at: 2.years.ago
    },
    {title: "Test Section 5",
     number: 5,
     modifiable: false,
     phase: insitution_template_phase_2,
     created_at: 2.years.ago
    },
    {title: "Test Section for the old version of Insitution Template",
      number: 11,
      modifiable: true,
      phase: Phase.find_by(title: "Phase 1 of Institutional Admin's Sample Template"),
      created_at: 2.years.ago
     },
     {title: "Test Section for the Institutional Template's Preliminary Phase - 1",
      number: 21,
      modifiable: true,
      phase: insitution_template_phase_2,
      created_at: 2.years.ago
     },
     {title: "Test Section for the Institutional Template's Preliminary Phase - 2",
      number: 22,
      modifiable: true,
      phase: insitution_template_phase_2,
      created_at: 2.years.ago
     },
     {title: "Test Section for the Orginisational Template's Detailed Phase - 1",
      number: 31,
      modifiable: false,
      phase: org_template_phase_1,
      created_at: 2.years.ago
     },
     {title: "Test Section for the Orginisational Template's Detailed Phase - 2",
      number: 32,
      modifiable: false,
      phase: org_template_phase_1,
      created_at: 2.years.ago
     },
     {title: "Test Section for the Orginisational Template's Detailed Phase - 3",
      number: 33,
      modifiable: false,
      phase: org_template_phase_1,
      created_at: 2.years.ago
     },
     {title: "Test Section for the Orginisational Template's Detailed Phase - 4",
      number: 34,
      modifiable: false,
      phase: org_template_phase_1,
      created_at: 2.years.ago
     },
     { title: "Test Section for the Orginisational Template's Detailed Phase - 5",
       number: 35,
       modifiable: false,
       phase: org_template_phase_1,
       created_at: 2.years.ago
      }
  ]
  sections.each{ |s| Section.create!(s) }
  
  
  # Create questions for templates using random theme
  # -------------------------------------------------------

  Section.all.each do |sec|
    text_area = QuestionFormat.find_by(title: "Text area")
    # Create 1 question to use in annotation
    q = {
        text: "A question with annotation",
        number: 0,
        section: sec,
        question_format: text_area,
        modifiable: false,
        themes:  [Theme.all.sample],
        created_at: 2.years.ago
       }
    Question.create!(q) 
    # For each section, generate 3 text_area questions using a random theme
    (1..3).each do |index|
        q = {
            text: Faker::Lorem.question,
            number: index,
            section: sec,
            question_format: text_area,
            modifiable: false,
            themes:  [Theme.all.sample],
            created_at: 2.years.ago
           }
        Question.create!(q) 
    end
    # For each section, generate 2 radio button questions using a random theme
    (1..2).each do |index|
        index = index + 10
        radio_button = Question.new(
            text: Faker::Lorem.question,
            number: index,
            section: sec,
            question_format: QuestionFormat.find_by(title: "Radio buttons"),
            modifiable: false,
            themes:  [Theme.all.sample],
            created_at: 2.years.ago
          )
        radio_button.question_options.build([
            {
                text: Faker::Lorem.word,
                number: 1,
                is_default: false
            },
            {
                text: Faker::Lorem.word,
                number: 2,
                is_default: false
            },
            {
                text: Faker::Lorem.word,
                number: 3,
                is_default: false
            }])
            radio_button.save!
    end
    # For each section, generate 2 checkbox questions using a random theme
    (1..2).each do |index|
      index = index + 100
      checkbox = Question.new(
        text: Faker::Lorem.question,
        number: index,
        section: sec,
        question_format: QuestionFormat.find_by(title: "Check box"),
        modifiable: false,
        themes:  [Theme.all.sample],
        created_at: 2.years.ago
      )
      checkbox.question_options.build([
        {
          text: Faker::Lorem.sentence,
          number: 1,
          is_default: true
        },
        {
          text: Faker::Lorem.sentence,
          number: 2,
          is_default: false
        },
        {
          text: Faker::Lorem.sentence,
          number: 3,
          is_default: false
        }])
        checkbox.save!
    end
    # For each section, generate 2 dropdown questions using a random theme
    (1..2).each do |index|
      index = index + 200
      dropdown = Question.new(
        text: Faker::Lorem.question,
        number: index,
        section: sec,
        question_format: QuestionFormat.find_by(title: "Dropdown"),
        modifiable: false,
        themes:  [Theme.all.sample],
        created_at: 2.years.ago
      )
      dropdown.question_options.build([
        {
          text:  Faker::Lorem.sentence,
          number: 1,
          is_default: false
        },
        {
          text:  Faker::Lorem.sentence,
          number: 2,
          is_default: false
        }])
      dropdown.save!
    end
    # For each section, generate 2 multi-select questions using a random theme
    (1..2).each do |index|
      index = index + 300
      multi_select_box = Question.new(
        text: Faker::Lorem.question,
        number: index,
        section: sec,
        question_format: QuestionFormat.find_by(title: "Multi select box"),
        option_comment_display: true,
        modifiable: false,
        themes:  [Theme.all.sample],
        created_at: 2.years.ago
      )
      multi_select_box.question_options.build([
        {
          text: Faker::Lorem.word,
          number: 1,
          is_default: false
        },
        {
          text: Faker::Lorem.word,
          number: 2,
          is_default: false
        },
        {
          text: Faker::Lorem.word,
          number: 3,
          is_default: false
        },
        {
          text: Faker::Lorem.word,
          number: 4,
          is_default: true
        }])
      multi_select_box.save!
    end
  end
  
  # Create suggested answers for a few questions
  # -------------------------------------------------------
  annotations = [
    {text: Faker::Lorem.question,
     type: Annotation.types[:example_answer],
     org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation),
     question: Question.find_by(text: "A question with annotation")},
     {text: Faker::Lorem.question,
      type: Annotation.types[:example_answer],
      org: Org.find_by(abbreviation: 'OEO'),
      question: Question.find_by(text: "A question with annotation")},
    {text: Faker::Lorem.question,
     type: Annotation.types[:example_answer],
     org: Org.find_by(abbreviation: 'IEO'),
     question: Question.find_by(text: "A question with annotation")},
  ]
  annotations.each{ |s| Annotation.create!(s) if Annotation.find_by(text: s[:text]).nil? }


  # Fake statistics for each of the three admin, up to 48 months back
  (1..48).each do |index|
    stat_details = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) } 
    stat_details2 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    stat_details3 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    @date = index.month.ago #date range
    @org = Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation) #the one that statistics belongs to
    @details = { "by_template": [stat_details, stat_details2], "using_template": [stat_details3] }
    stat_created_plan = {date: @date, org: @org, details: @details, filtered: 0, count:Faker::Number.number(digits: 2)}
    StatCreatedPlan.create(stat_created_plan)
    stat_shared_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatSharedPlan.create(stat_shared_plan)
    stat_joined_user = {date: @date, org: @org, count: Faker::Number.number(digits: 2)}
    StatJoinedUser.create(stat_joined_user)
    stat_exported_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatExportedPlan.create(stat_exported_plan)  
  end

  (1..48).each do |index|
    stat_details = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) } 
    stat_details2 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    stat_details3 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    @date = index.month.ago #date range
    @org = Org.find_by(abbreviation: "IEO")
    @details = { "by_template": [stat_details, stat_details2], "using_template": [stat_details3] }
    stat_created_plan = {date: @date, org: @org, details: @details, filtered: 0, count:Faker::Number.number(digits: 2)}
    StatCreatedPlan.create(stat_created_plan)
    stat_shared_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatSharedPlan.create(stat_shared_plan)
    stat_joined_user = {date: @date, org: @org, count: Faker::Number.number(digits: 2)}
    StatJoinedUser.create(stat_joined_user)
    stat_exported_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatExportedPlan.create(stat_exported_plan)
  end

  (1..48).each do |index|
    stat_details = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) } 
    stat_details2 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    stat_details3 = { "name": Org.all.sample.name, "count": Faker::Number.number(digits: 2) }
    @date = index.month.ago #date range
    @org = Org.find_by(abbreviation: "OEO")
    @details = { "by_template": [stat_details, stat_details2], "using_template": [stat_details3] }
    stat_created_plan = {date: @date, org: @org, details: @details, filtered: 0, count:Faker::Number.number(digits: 2)}
    StatCreatedPlan.create(stat_created_plan)
    stat_shared_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatSharedPlan.create(stat_shared_plan)
    stat_joined_user = {date: @date, org: @org, count: Faker::Number.number(digits: 2)}
    StatJoinedUser.create(stat_joined_user)
    stat_exported_plan = {date: @date, org: @org, count:Faker::Number.number(digits: 1)}
    StatExportedPlan.create(stat_exported_plan)
  end

  # Create some existing plans for admins
  # ---------------------------------------------------------
  # Plans are created within 1 year for statistics

  # Plan crated by super admin, using organisational admin's org template
   (1..20).each do |index|
    template_org = Org.find_by(abbreviation: "OEO")
    title = "Test Plan " + index.to_s + " using Template from " + template_org.name
    plan = {
      title: title,
      created_at: index.month.ago,
      updated_at: index.month.ago,
      template: Template.find_by(org_id: template_org.id),
      identifier: index,
      description: Faker::Lorem.paragraph,
      visibility: [0,1,2,3].sample,
      feedback_requested: false,
      complete: false,
      org: Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation)
    }
    Plan.create!(plan)
    role = {
      user: User.find_by(email: "dmp.super.admin@engagedri.ca"),
      plan: Plan.find_by(title:title),
      created_at: index.month.ago,
      updated_at: index.month.ago,
      access: [8,12,14,15].sample,
      active: 1
    }
    Role.create!(role)
  end
  # Plan created by insitutional admin, using super admin's org template
  (1..20).each do |index|
    template_org = Org.find_by(abbreviation: Rails.configuration.x.organisation.abbreviation)
    title = "Test Plan Under " + template_org.name + " " + index.to_s
    plan = {
      title: title,
      created_at: index.month.ago,
      updated_at: index.month.ago,
      template: Template.find_by(org_id: template_org.id),
      identifier: index,
      description: Faker::Lorem.paragraph,
      visibility: [0,1,2,3].sample,
      feedback_requested: false,
      complete: false,
      org: Org.find_by(abbreviation: "IEO")
    }
    Plan.create!(plan)
    role = {
      user: User.find_by(email: "dmp.insitution.admin@engagedri.ca"),
      plan: Plan.find_by(title:title),
      created_at: index.month.ago,
      updated_at: index.month.ago,
      access: [8,12,14,15].sample,
      active: 1
    }
    Role.create!(role)
  end
  # Plan created by org admin, using instutional admin's org template
  (1..20).each do |index|
    template_org = Org.find_by(abbreviation: "IEO")
    title = "Test Plan Under " + template_org.name + " " + index.to_s
    plan = {
      title: title,
      created_at: index.month.ago,
      updated_at: index.month.ago,
      template: Template.find_by(org_id: template_org.id),
      identifier: index,
      description: Faker::Lorem.paragraph,
      visibility: [0,1,2,3].sample,
      feedback_requested: false,
      complete: false,
      org: Org.find_by(abbreviation: "OEO")
    }
    Plan.create!(plan)
    role = {
      user: User.find_by(email: "dmp.organisation.admin@engagedri.ca"),
      plan: Plan.find_by(title:title),
      created_at: index.month.ago,
      updated_at: index.month.ago,
      access: [8,12,14,15].sample,
      active: 1
    }
    Role.create!(role)
  end
