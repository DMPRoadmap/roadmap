# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Identifier Schemes
# -------------------------------------------------------
identifier_schemes = [
  {name: 'orcid', description: 'ORCID', active: true,
   logo_url:'http://orcid.org/sites/default/files/images/orcid_16x16.png',
   user_landing_url:'https://orcid.org' },
  {name: 'shibboleth', description: 'Your institutional credentials', active: true,
  },
]
identifier_schemes.map{ |is| IdentifierScheme.create!(is) if IdentifierScheme.find_by(name: is[:name]).nil? }

# Question Formats
# -------------------------------------------------------
question_formats = [
  {title: "Text area", option_based: false, formattype: 0},
  {title: "Text field", option_based: false, formattype: 1},
  {title: "Radio buttons", option_based: true, formattype: 2},
  {title: "Check box", option_based: true, formattype: 3},
  {title: "Dropdown", option_based: true, formattype: 4},
  {title: "Multi select box", option_based: true, formattype: 5},
  {title: "Date", option_based: true, formattype: 6}
]
question_formats.map{ |qf| QuestionFormat.create!(qf) if QuestionFormat.find_by(title: qf[:title]).nil? }

# Languages (check config/locales for any ones not defined here)
# -------------------------------------------------------
languages = [
  {abbreviation: 'en_GB',
   description: '',
   name: 'English (GB)',
   default_language: true},
  {abbreviation: 'en_US',
   description: '',
   name: 'English (US)',
   default_language: false},
  {abbreviation: 'fr',
   description: '',
   name: 'Français',
   default_language: false},
  {abbreviation: 'de',
   description: '',
   name: 'Deutsch',
   default_language: false},
  {abbreviation: 'es',
   description: '',
   name: 'Español',
   default_language: false},
  {abbreviation: 'pt-BR',
    description: '',
    name: 'Português (Brasil)',
    default_language: false},
  {abbreviation: 'ja',
   description: '',
   name: '日本語',
   default_language: false}
]
languages.map{ |l| Language.create!(l) if Language.find_by(abbreviation: l[:abbreviation]).nil? }

# Scan through the locale files and add an entry if a file is present but
# not defined in this seed file
Dir.entries("#{Rails.root.join("config", "locales").to_s}").each do |f|
  if f[-4..-1] == '.yml'
    lang = f.gsub('.yml', '')

    if Language.where(abbreviation: lang).empty?
      Language.create!({
        abbreviation: lang,
        description: lang,
        name: lang,
        default_language: false
      })
    end
  end
end

# Regions (create the super regions first and then create the rest)
# -------------------------------------------------------
regions = [
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
  {name: 'grant_api_to_orgs'}
]

perms.map{ |p| Perm.create!(p) if Perm.find_by(name: p[:name]).nil? }

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
themes.map{ |t| Theme.create!(t) if Theme.find_by(title: t[:title]).nil? }

# Token Permission Types
# -------------------------------------------------------
token_permission_types = [
  {token_type: 'guidances', text_description: 'allows a user access to the guidances api endpoint'},
  {token_type: 'plans', text_description: 'allows a user access to the plans api endpoint'},
  {token_type: 'templates', text_description: 'allows a user access to the templates api endpoint'},
  {token_type: 'statistics', text_description: 'allows a user access to the statistics api endpoint'}
]
token_permission_types.map{ |tpt| TokenPermissionType.create!(tpt) if TokenPermissionType.find_by(token_type: tpt[:token_type]).nil? }

# Create our generic organisation, a funder and a University
# -------------------------------------------------------
orgs = [
  {name: Rails.configuration.branding[:organisation][:name],
   abbreviation: Rails.configuration.branding[:organisation][:abbreviation],
   org_type: 4, links: {"org":[]},
   language_id: Language.find_by(abbreviation: 'en_GB'),
   token_permission_types: TokenPermissionType.all},
  {name: 'Government Agency',
   abbreviation: 'GA',
   org_type: 2, links: {"org":[]},
   language: Language.find_by(abbreviation: 'en_GB')},
  {name: 'University of Exampleland',
   abbreviation: 'UOS',
   org_type: 1, links: {"org":[]},
   language: Language.find_by(abbreviation: 'en_GB')}
]
orgs.map{ |o| Org.create!(o) if Org.find_by(abbreviation: o[:abbreviation]).nil? }

# Create a Super Admin associated with our generic organisation,
# an Org Admin for our funder and an Org Admin and User for our University
# -------------------------------------------------------
users = [
  {email: "super_admin@example.com",
   firstname: "Super",
   surname: "Admin",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: Rails.configuration.branding[:organisation][:abbreviation]),
   language: Language.find_by(abbreviation: FastGettext.locale),
   perms: Perm.all,
   accept_terms: true,
   api_token: 'abcd1234',
   confirmed_at: Time.zone.now},
  {email: "funder_admin@example.com",
   firstname: "Funder",
   surname: "Admin",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: 'GA'),
   language: Language.find_by(abbreviation: FastGettext.locale),
   perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
   accept_terms: true,
   api_token: 'efgh5678',
   confirmed_at: Time.zone.now},
  {email: "org_admin@example.com",
   firstname: "Organisational",
   surname: "Admin",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: 'UOS'),
   language: Language.find_by(abbreviation: FastGettext.locale),
   perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']),
   accept_terms: true,
   api_token: 'ijkl9012',
   confirmed_at: Time.zone.now},
  {email: "org_user@example.com",
   firstname: "Organisational",
   surname: "User",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: 'UOS'),
   language: Language.find_by(abbreviation: FastGettext.locale),
   accept_terms: true,
   confirmed_at: Time.zone.now}
]
users.map{ |u| User.create!(u) if User.find_by(email: u[:email]).nil? }

# Create a Guidance Group for our organisation and the funder
# -------------------------------------------------------
guidance_groups = [
  {name: "Generic Guidance (provided by the example curation centre)",
   org: Org.find_by(abbreviation: Rails.configuration.branding[:organisation][:abbreviation]),
   optional_subset: true,
   published: true},
  {name: "Government Agency Advice (Funder specific guidance)",
   org: Org.find_by(abbreviation: 'GA'),
   optional_subset: false,
   published: true}
]
guidance_groups.map{ |gg| GuidanceGroup.create!(gg) if GuidanceGroup.find_by(name: gg[:name]).nil? }

# Initialize with the generic Roadmap guidance and a sample funder guidance
# -------------------------------------------------------
guidances = [
  {text: "● Give a summary of the data you will collect or create, noting the content, coverage and data type, e.g., tabular data, survey data, experimental measurements, models, software, audiovisual data, physical samples, etc.
● Consider how your data could complement and integrate with existing data, or whether there are any existing data or methods that you could reuse.
● If purchasing or reusing existing data, explain how issues such as copyright and IPR have been addressed. You should aim to m
inimise any restrictions on the reuse (and subsequent sharing) of third-party data.",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Data Description')]},
  {text: "● Clearly note what format(s) your data will be in, e.g., plain text (.txt), comma-separated values (.csv), geo-referenced TIFF (.tif, .tfw).
● Explain why you have chosen certain formats. Decisions may be based on staff expertise, a preference for open formats, the standards accepted by data centres or widespread usage within a given community.
● Using standardised, interchangeable or open formats ensures the long-term usability of data; these are recommended for sharing and archiving.
● See <a href='https://www.ukdataservice.ac.uk/manage-data/format/recommended-formats' title='UK Data Service guidance on recommended formats'>UK Data Service guidance on recommended formats</a> or <a href='https://www.dataone.org/best-practices/document-and-store-data-using-stable-file-formats' title='DataONE Best Practices for file formats'>DataONE Best Practices for file formats</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Data Format')]},
  {text: "● Note what volume of data you will create in MB/GB/TB
● Consider the implications of data volumes in terms of storage, access and preservation. Do you need to include additional costs?
● Consider whether the scale of the data will pose challenges when sharing or transferring data between sites; if so, how will you address these challenges?",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Data Volume')]},
  {text: "● Outline how the data will be collected and processed. This should cover relevant standards or methods, quality assurance and data organisation.
● Indicate how the data will be organised during the project, mentioning, e.g., naming conventions, version control and folder structures. Consistent, well-ordered research data will be easier to find, understand and reuse
● Explain how the consistency and quality of data collection will be controlled and documented. This may include processes such as calibration, repeat samples or measurements, standardised data capture, data entry validation, peer review of data or representation with controlled vocabularies.
● See the <a href='https://www.dataone.org/best-practices/quality' title='DataOne Best Practices for data quality'>DataOne Best Practices for data quality</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Data Collection')]},
  {text: "● What metadata will be provided to help others identify and discover the data?
● Researchers are strongly encouraged to use community metadata standards where these are in place. The Research Data Alliance offers a <a href='http://rd-alliance.github.io/metadata-directory' title='Directory of Metadata Standards'>Directory of Metadata Standards</a>.
● Consider what other documentation is needed to enable reuse. This may include information on the methodology used to collect the data, analytical and procedural information, definitions of variables, units of measurement, any assumptions made, the format and file type of the data and software used to collect and/or process the data.
● Consider how you will capture this information and where it will be recorded, e.g., in a database with links to each item, in a ‘readme’ text file, in file headers, etc. ",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Metadata & Documentation')]},
  {text: "● Investigators carrying out research involving human participants should request consent to preserve and share the data. Do not just ask for permission to use the data in your study or make unnecessary promises to delete it at the end.
● Consider how you will protect the identity of participants, e.g., via anonymisation or using managed access procedures.
● Ethical issues may affect how you store and transfer data, who can see/use it and how long it is kept. You should demonstrate that you are aware of this and have planned accordingly.
● See <a href='https://www.ukdataservice.ac.uk/manage-data/legal-ethical/consent-data-sharing' title='UK Data Service guidance on consent for data sharing'>UK Data Service guidance on consent for data sharing</a>
● See <a href='http://www.icpsr.umich.edu/icpsrweb/content/datamanagement/confidentiality/index.html' title='ICPSR approach to confidentiality'>ICPSR approach to confidentiality</a> and Health Insurance Portability and Accountability Act <a href='https://privacyruleandresearch.nih.gov/' title='(HIPAA) regulations for health research'>(HIPAA) regulations for health research</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Ethics & Privacy')]},
  {text: "● State who will own the copyright and IPR of any new data that you will generate. For multi-partner projects, IPR ownership should be covered in the consortium agreement.
● Outline any restrictions needed on data sharing, e.g., to protect proprietary or patentable data.
● Explain how the data will be licensed for reuse. See the <a href='http://www.dcc.ac.uk/resources/how-guides/license-research-data' title='DCC guide on How to license research data'>DCC guide on How to license research data</a> and <a href='https://ufal.github.io/public-license-selector' title='EUDAT’s data and software licensing wizard'>EUDAT’s data and software licensing wizard</a>.",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Intellectual Property Rights')]},
  {text: "● Describe where the data will be stored and backed up during the course of research activities. This may vary if you are doing fieldwork or working across multiple sites so explain each procedure.
● Identify who will be responsible for backup and how often this will be performed. The use of robust, managed storage with automatic backup, for example, that provided by university IT teams, is preferable. Storing data on laptops, computer hard drives or external storage devices alone is very risky.
● See <a href='https://www.ukdataservice.ac.uk/manage-data/store' title='UK Data Service Guidance on data storage'>UK Data Service Guidance on data storage</a> or <a href='https://www.dataone.org/best-practices/storage' title='DataONE Best Practices for storage'>DataONE Best Practices for storage</a>
● Also consider data security, particularly if your data is sensitive e.g., detailed personal data, politically sensitive information or trade secrets. Note the main risks and how these will be managed.
● Identify any formal standards that you will comply with, e.g., ISO 27001. See the <a href='http://www.dcc.ac.uk/resources/briefing-papers/standards-watch-papers/information-security-management-iso-27000-iso-27k-s' title='DCC Briefing Paper on Information Security Management -ISO 27000'>DCC Briefing Paper on Information Security Management -ISO 27000</a> and <a href='https://www.ukdataservice.ac.uk/manage-data/store/security' title='UK Data Service guidance on data security'>UK Data Service guidance on data security</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Storage & Security')]},
  {text: "● How will you share the data e.g. deposit in a data repository, use a secure data service, handle data requests directly or use another mechanism? The methods used will depend on a number of factors such as the type, size, complexity and sensitivity of the data.
● When will you make the data available? Research funders expect timely release. They typically allow embargoes but not prolonged exclusive use.
● Who will be able to use your data? If you need to restricted access to certain communities or apply data sharing agreements, explain why.
● Consider strategies to minimise restrictions on sharing. These may include anonymising or aggregating data, gaining participant consent for data sharing, gaining copyright permissions, and agreeing a limited embargo period.
● How might your data be reused in other contexts? Where there is potential for reuse, you should use standards and formats that facilitate this, and ensure that appropriate metadata is available online so your data can be discovered. Persistent identifiers should be applied so people can reliably and efficiently find your data. They also help you to track citations and reuse.",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Data Sharing')]},
  {text: "● Where will the data be deposited? If you do not propose to use an established repository, the data management plan should demonstrate that the data can be curated effectively beyond the lifetime of the grant.
● It helps to show that you have consulted with the repository to understand their policies and procedures, including any metadata standards.
● An international list of data repositories is available via <a href='http://www.re3data.org/' title='Re3data'>Re3data</a> and some universities or publishers provide lists of recommendations e.g. <a href='http://journals.plos.org/plosone/s/data-availability#loc-recommended-repositories' title='PLOS ONE recommended repositories'>PLOS ONE recommended repositories</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Data Repository')]},
  {text: "● Indicate which data are of long-term value and should be shared and/or preserved.
● Outline the plans for data sharing and preservation - how long will the data be retained and where will it be archived?
● Will additional resources be needed to prepare data for deposit or meet any charges from data repositories? See the DCC guide: <a href='http://www.dcc.ac.uk/resources/how-guides/appraise-select-data' title='How to appraise and select research data for curation'>How to appraise and select research data for curation</a> or DataONE Best Practices: <a href='https://www.dataone.org/best-practices/identify-data-long-term-value' title='Identifying data with long-term value'>Identifying data with long-term value</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Preservation')]},
  {text: "● Outline the roles and responsibilities for all activities, e.g., data capture, metadata production, data quality, storage and backup, data archiving & data sharing. Individuals should be named where possible.
● For collaborative projects you should explain the coordination of data management responsibilities across partners.
● See UK Data Service guidance on <a href='https://www.ukdataservice.ac.uk/manage-data/plan/roles-and-responsibilities' title='data management roles and responsibilities'>data management roles and responsibilities</a> or DataONE Best Practices: <a href='https://www.dataone.org/best-practices/define-roles-and-assign-responsibilities-data-management' title='Define roles and assign responsibilities for data management'>Define roles and assign responsibilities for data management</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Roles & Responsibilities')]},
  {text: "● Carefully consider and justify any resources needed to deliver the plan.  These may include storage costs, hardware, staff time, costs of preparing data for deposit and repository charges.
● Outline any relevant technical expertise, support and training that is likely to be required and how it will be acquired.
● If you are not depositing in a data repository, ensure you have appropriate resources and systems in place to share and preserve the data. See UK Data Service guidance on <a href='https://www.ukdataservice.ac.uk/manage-data/plan/costing' title='costing data management'>costing data management</a>",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Budget')]},
  {text: "● Consider whether there are any existing procedures that you can base your approach on. If your group/department has local guidelines that you work to, point to them here.
● List any other relevant funder, institutional, departmental or group policies on data management, data sharing and data security. ",
   guidance_group: GuidanceGroup.first,
   published: true,
   themes: [Theme.find_by(title: 'Related Policies')]},
  {text: "Please tell us how much data you plan to collect and what format it will be in once its deposited.",
   guidance_group: GuidanceGroup.last,
   published: true,
   themes: [Theme.find_by(title: 'Data Description')]}
]
guidances.map{ |g| Guidance.create!(g) if Guidance.find_by(text: g[:text]).nil? }

# Create a default template for the curation centre and one for the example funder
# -------------------------------------------------------
templates = [
  {title: "My Curation Center's Default Template",
   description: "The default template",
   published: true,
   org: Org.find_by(abbreviation: Rails.configuration.branding[:organisation][:abbreviation]),
   is_default: true,
   version: 0,
   migrated: false,
   dmptemplate_id: 1,
   visibility: Template.visibilities[:publicly_visible],
   links: {"funder":[],"sample_plan":[]}},

  {title: "OLD - Department of Testing Award",
   published: false,
   org: Org.find_by(abbreviation: 'GA'),
   is_default: false,
   version: 0,
   migrated: false,
   visibility: Template.visibilities[:organisationally_visible],
   dmptemplate_id: 2,
   links: {"funder":[],"sample_plan":[]}},

  {title: "Department of Testing Award",
   published: true,
   org: Org.find_by(abbreviation: 'GA'),
   is_default: false,
   version: 0,
   migrated: false,
   visibility: Template.visibilities[:organisationally_visible],
   dmptemplate_id: 3,
   links: {"funder":[],"sample_plan":[]}}
]
# Template creation calls defaults handler which sets is_default and
# published to false automatically, so update them after creation
templates.map do |t|
  if Template.find_by(title: t[:title]).nil?
    tmplt = Template.create!(t)
    tmplt.published = t[:published]
    tmplt.is_default = t[:is_default]
    tmplt.visibility = t[:visibility]
    tmplt.save!
  end
end

# Create 2 phases for the funder's template and one for our generic template
# -------------------------------------------------------
phases = [
  {title: "Generic Data Management Planning Template",
   number: 1,
   modifiable: false,
   template: Template.find_by(title: "My Curation Center's Default Template")},

  {title: "Detailed Overview",
    number: 1,
    modifiable: false,
    template: Template.find_by(title: "OLD - Department of Testing Award")},

  {title: "Preliminary Statement of Work",
   number: 1,
   modifiable: true,
   template: Template.find_by(title: "Department of Testing Award")},
  {title: "Detailed Overview",
   number: 2,
   modifiable: false,
   template: Template.find_by(title: "Department of Testing Award")}
]
phases.map{ |p| Phase.create!(p) if Phase.find_by(title: p[:title]).nil? }

generic_template_phase_1 = Phase.find_by(title: "Generic Data Management Planning Template")
funder_template_phase_1 = Phase.find_by(title: "Preliminary Statement of Work")
funder_template_phase_2 = Phase.find_by(title: "Detailed Overview")

# Create sections for the 2 templates and their phases
# -------------------------------------------------------
sections = [
  # Sections for the Generic Template
  {title: "Data Collection",
   number: 1,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},
  {title: "Documentation and Metadata",
   number: 2,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},
  {title: "Ethics and Legal Compliance",
   number: 3,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},
  {title: "Storage and Backup",
   number: 4,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},
  {title: "Selection and Preservation",
   number: 5,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},
  {title: "Data Sharing",
   number: 6,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},
  {title: "Responsibilities and Resources",
   number: 7,
   published: true,
   modifiable: false,
   phase: generic_template_phase_1},

  # Section of old version of Funder Template
  {title: "Data Collection and Preservation",
   number: 1,
   published: false,
   modifiable: true,
   phase: Phase.find_by(title: "Detailed Overview")},

  # Sections for the Funder Template's Preliminary Phase
  {title: "Data Overview",
   number: 1,
   published: false,
   modifiable: true,
   phase: funder_template_phase_1},
  {title: "Data Description",
   number: 1,
   published: false,
   modifiable: true,
   phase: funder_template_phase_1},

  # Sections for the Funder Template's Detailed Phase
  {title: "Preservation Policy",
   number: 1,
   published: true,
   modifiable: false,
   phase: funder_template_phase_2},
  {title: "Data Format and Storage",
   number: 1,
   published: true,
   modifiable: false,
   phase: funder_template_phase_2},
  {title: "Collection Process",
   number: 1,
   published: true,
   modifiable: false,
   phase: funder_template_phase_2},
  {title: "Ethical Standards",
   number: 1,
   published: true,
   modifiable: false,
   phase: funder_template_phase_2},
  {title: "Preservation and Reuse Policies",
   number: 1,
   published: true,
   modifiable: false,
   phase: funder_template_phase_2}
]
sections.map{ |s| Section.create!(s) if Section.find_by(title: s[:title]).nil? }

text_area = QuestionFormat.find_by(title: "Text area")

# Create questions for the 2 templates and their phases
# -------------------------------------------------------
questions = [
  # Questions for the Generic Template
  {text: "What data will you collect or create?",
   number: 1,
   section: Section.find_by(title: "Data Collection"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Data Description")]},
  {text: "How will the data be collected or created?",
   number: 2,
   section: Section.find_by(title: "Data Collection"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Data Collection")]},
  {text: "What documentation and metadata will accompany the data?",
   number: 1,
   section: Section.find_by(title: "Documentation and Metadata"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Metadata & Documentation")]},
  {text: "How will you manage any ethical issues?",
   number: 1,
   section: Section.find_by(title: "Ethics and Legal Compliance"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Ethics & Privacy")]},
  {text: "How will you manage copyright and Intellectual Property Rights (IPR) issues?",
   number: 2,
   section: Section.find_by(title: "Ethics and Legal Compliance"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Intellectual Property Rights")]},
  {text: "How will the data be stored and backed up during the research?",
   number: 1,
   section: Section.find_by(title: "Storage and Backup"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Storage & Security")]},
  {text: "How will you manage access and security?",
   number: 2,
   section: Section.find_by(title: "Storage and Backup"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Storage & Security")]},
  {text: "Which data are of long-term value and should be retained, shared, and/or preserved?",
   number: 1,
   section: Section.find_by(title: "Selection and Preservation"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Preservation")]},
  {text: "What is the long-term preservation plan for the dataset?",
   number: 2,
   section: Section.find_by(title: "Selection and Preservation"),
   question_format: text_area,
   modifiable: false},
  {text: "How will you share the data?",
   number: 1,
   section: Section.find_by(title: "Data Sharing"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Data Sharing")]},
  {text: "Are any restrictions on data sharing required?",
   number: 2,
   section: Section.find_by(title: "Data Sharing"),
   question_format: text_area,
   modifiable: false},
  {text: "Who will be responsible for data management?",
   number: 1,
   section: Section.find_by(title: "Responsibilities and Resources"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Roles & Responsibilities")]},
  {text: "What resources will you require to deliver your plan?",
   number: 2,
   modifiable: false,
   section: Section.find_by(title: "Responsibilities and Resources"),
   question_format: text_area},

  # Questions for old version of Funder Template
  {text: "What data will you collect and how will it be obtained?",
   number: 1,
   modifiable: false,
   section: Section.find_by(title: "Data Collection and Preservation"),
   question_format: text_area},
  {text: "How will you preserve your data during the project and long-term?",
   number: 2,
   modifiable: false,
   section: Section.find_by(title: "Data Collection and Preservation"),
   question_format: text_area},

  # Questions for the Funder Template's Preliminary Phase
  {text: "Provide an overview of the dataset.",
   number: 1,
   section: Section.find_by(title: "Data Overview"),
   question_format: text_area,
   modifiable: true,
   themes: [Theme.find_by(title: "Data Description")]},
  {text: "What types/formats of data will you collect?",
   number: 1,
   modifiable: true,
   section: Section.find_by(title: "Data Description"),
   question_format: text_area,
   themes: [Theme.find_by(title: "Data Format")]},
  {text: "How will you store the data and how will it be preserved?",
   number: 2,
   modifiable: true,
   section: Section.find_by(title: "Data Description"),
   question_format: text_area,
   themes: [Theme.find_by(title: "Data Collection")]},

  # Questions for the Funder Template's Detailed Phase
  {text: "What is your policy for long term access to your dataset?",
   number: 1,
   section: Section.find_by(title: "Preservation Policy"),
   question_format: text_area,
   modifiable: false,
   default_value: "Please enter your answer here ..." ,
   themes: [Theme.find_by(title: "Preservation")]},
  {text: "Where will your data be preserved?",
   number: 2,
   section: Section.find_by(title: "Preservation Policy"),
   question_format: QuestionFormat.find_by(title: "Text field"),
   modifiable: false,
   default_value: "on a server at my institution",
   themes: [Theme.find_by(title: "Preservation")]},
  {text: "What types of data will you collect and how will it be stored?",
   number: 1,
   section: Section.find_by(title: "Data Format and Storage"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Storage & Security"), Theme.find_by(title: 'Data Format')]},
  {text: "Please select the appropriate formats.",
   number: 2,
   section: Section.find_by(title: "Data Format and Storage"),
   question_format: QuestionFormat.find_by(title: "Radio buttons"),
   modifiable: false,
   themes: [Theme.find_by(title: "Storage & Security"), Theme.find_by(title: 'Data Format')]},
  {text: "Will software accompany your dataset?",
   number: 1,
   section: Section.find_by(title: "Collection Process"),
   question_format: QuestionFormat.find_by(title: "Check box"),
   modifiable: false,
   themes: [Theme.find_by(title: "Data Collection")]},
  {text: "Where will you store your data during the research period?",
   number: 2,
   section: Section.find_by(title: "Collection Process"),
   question_format: QuestionFormat.find_by(title: "Dropdown"),
   modifiable: false,
   themes: [Theme.find_by(title: "Data Collection")]},
  {text: "What type(s) of data will you collect?",
   number: 3,
   section: Section.find_by(title: "Collection Process"),
   question_format: QuestionFormat.find_by(title: "Multi select box"),
   option_comment_display: true,
   modifiable: false,
   themes: [Theme.find_by(title: "Data Collection")]},
  {text: "What are your institution's ethical policies?",
   number: 1,
   section: Section.find_by(title: "Ethical Standards"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Ethics & Privacy")]},
  {text: "When will your data be available for public consumption?",
   number: 2,
   section: Section.find_by(title: "Ethical Standards"),
   question_format: QuestionFormat.find_by(title: "Date"),
   modifiable: false,
   themes: [Theme.find_by(title: "Ethics & Privacy")]},
  {text: "Tell us about your departmental and institutional policies on reuse and preservation.",
   number: 1,
   section: Section.find_by(title: "Preservation and Reuse Policies"),
   question_format: text_area,
   modifiable: false,
   themes: [Theme.find_by(title: "Preservation"), Theme.find_by(title: "Data Sharing")]}
]
questions.map{ |q| Question.create!(q) if Question.find_by(text: q[:text]).nil? }

drop_down_question = Question.find_by(text: "Where will you store your data during the research period?")
multi_select_question = Question.find_by(text: "What type(s) of data will you collect?")
radio_button_question = Question.find_by(text: "Please select the appropriate formats.")

# Create suggested answers for a few questions
# -------------------------------------------------------
annotations = [
  {text: "We will preserve it in Dryad or a similar data repository service.",
   type: Annotation.types[:example_answer],
   org: Org.find_by(abbreviation: 'GA'),
   question: Question.find_by(text: "What is your policy for long term access to your dataset?")},
  {text: "We recommend that you identify the type(s) of content as well as the type of file(s) involved",
   type: Annotation.types[:example_answer],
   org: Org.find_by(abbreviation: 'GA'),
   question: Question.find_by(text: "What types of data will you collect and how will it be stored?")},
]
annotations.map{ |s| Annotation.create!(s) if Annotation.find_by(text: s[:text]).nil? }

# Create options for the dropdown, multi-select and radio buttons
# -------------------------------------------------------
question_options = [
  {text: "csv files",
   number: 1,
   question: radio_button_question,
   is_default: false},
  {text: "database (e.g. mysql, redis)",
   number: 2,
   question: radio_button_question,
   is_default: false},
  {text: "archive files (e.g. tar, zip)",
   number: 3,
   question: radio_button_question,
   is_default: false},

  {text: "local hard drive",
   number: 1,
   question: drop_down_question,
   is_default: true},
  {text: "personal cloud storage",
   number: 2,
   question: drop_down_question,
   is_default: false},
  {text: "institutional servers",
   number: 3,
   question: drop_down_question,
   is_default: false},

  {text: "statistical",
   number: 1,
   question: multi_select_question,
   is_default: false},
  {text: "image/video",
   number: 2,
   question: multi_select_question,
   is_default: false},
  {text: "geographical",
   number: 3,
   question: multi_select_question,
   is_default: false},
  {text: "other",
   number: 4,
   question: multi_select_question,
   is_default: false}
]
question_options.map{ |q| QuestionOption.create!(q) if QuestionOption.find_by(text: q[:text]).nil? }

# Create plans
# -------------------------------------------------------
=begin
plans = [
  {title: "Sample plan",
   template: Template.find_by(title: "Department of Testing Award"),
   grant_number: "FUNDER-GRANT-123",
   identifier: "987654321",
   description: "This is a sample plan based on a funder template",
   principal_investigator: "John Doe",
   principal_investigator_identifier: "ORCID: 12346-000-1234",
   data_contact: "john.doe@example.com",
   funder_name: "Example Government Agency",
   visibility: 0}
]
plans.map{ |p| Plan.create!(p) if Plan.find_by(title: "Sample plan").nil? }

plan = Plan.find_by(title: "Sample plan")
user = User.find_by(email: "org_user@example.com")

answers = [
  {text: "We will collect data from various sources and create our own analysis.",
   plan: plan,
   user: user,
   question: Question.find_by(text: "Provide an overview of the dataset.")},
  {text: "We will primarily collect images and video from our telescope and other instruments",
   plan: plan,
   user: user,
   question: Question.find_by(text: "What types/formats of data will you collect?")},
  {text: "We will store the data on our departmental server and then move it to a commercial data repository afterward.",
   plan: plan,
   user: user,
   question: Question.find_by(text: "How will you store the data and how will it be preserved?")},

  {text: "We want people to be able to access it. ",
   plan: plan,
   user: user,
   question: Question.find_by(text: "What is your policy for long term access to your dataset?")},
  {plan: plan,
   user: user,
   question: drop_down_question,
   question_options: [QuestionOption.find_by(text: "institutional servers")]},
  {plan: plan,
   user: user,
   question: multi_select_question,
   question_options: [QuestionOption.find_by(text: "image/video"),
                      QuestionOption.find_by(text: "other")]},
  {plan: plan,
   user: user,
   question: radio_button_question,
   question_options: [QuestionOption.find_by(text: "archive files (e.g. tar, zip)"),
                      QuestionOption.find_by(text: "csv files")]},
  {text: "Yes",
   plan: plan,
   user: user,
   question: Question.find_by(text: "Will software accompany your dataset?")},
  {text: "On a local server",
   plan: plan,
   user: user,
   question: Question.find_by(text: "Where will you store your data during the research period?")},
   {text: "2018-05-01 00:00:01",
    plan: plan,
    user: user,
    question: Question.find_by(text: "When will your data be available for public consumption?")}
]
answers.map{ |a| Answer.create!(a) if Answer.where(plan: a[:plan], user: a[:user], question: a[:question]).empty? }
=end
