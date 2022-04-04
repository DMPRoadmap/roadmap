## Pre-setting: the default_funder in the env must be set to "Digital Research Alliance of Canada"

  #####################################
  ### Manually defined seed data just for sandbox testing 
  #####################################

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
  
  # Token Permission Types
  # -------------------------------------------------------
  token_permission_types = [
    {token_type: 'guidances', text_description: 'allows a user access to the guidances api endpoint'},
    {token_type: 'plans', text_description: 'allows a user access to the plans api endpoint'},
    {token_type: 'templates', text_description: 'allows a user access to the templates api endpoint'},
    {token_type: 'statistics', text_description: 'allows a user access to the statistics api endpoint'}
  ]
  token_permission_types.each{ |tpt| TokenPermissionType.create!(tpt) }
  
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
  
  

 #####################################
  ### Now Proceed to seeds_1.rb: 
  ### Export from Database Directly. 
  ### Should be updated by running export_to_seeds rake task and paste new data in seeds_1.rb
  #####################################