# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Identifier Schemes
# -------------------------------------------------------
identifier_schemes = [
  {name: 'orcid', description: 'ORCID researcher identifiers', active: true},
  {name: 'shibboleth', description: 'Shibboleth', active: false},
  {name: 'facebook', description: 'Facebook OAuth', active: false}
]
identifier_schemes.map{ |is| IdentifierScheme.create!(is) if IdentifierScheme.find_by(name: is[:name]).nil? }

# Question Formats
# -------------------------------------------------------
question_formats = [
  {title: "Text area"},
  {title: "Text field"},
  {title: "Radio buttons"},
  {title: "Check box"},
  {title: "Dropdown"},
  {title: "Multi select box"},
  {title: "Date"}
]
question_formats.map{ |qf| QuestionFormat.create!(qf) if QuestionFormat.find_by(title: qf[:title]).nil? }

# Languages (check config/locales for any ones not defined here)
# -------------------------------------------------------
languages = [
  {abbreviation: 'en-UK',
   description: 'UK English',
   name: 'English (UK)',
   default_language: true},
  {abbreviation: 'en-US',
   description: 'US English',
   name: 'English (US)',
   default_language: false},
  {abbreviation: 'fr',
   description: 'French',
   name: 'French',
   default_language: false},
  {abbreviation: 'de',
   description: 'German',
   name: 'German',
   default_language: false},
  {abbreviation: 'es',
   description: 'Spanish',
   name: 'Spanish',
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
  
  region = Region.create!(r) if Region.find_by(abbreviation: r[:abbreviation]).nil?
  
  unless srs.nil?
    srs.each do |sr|
      if Region.find_by(abbreviation: sr[:abbreviation]).nil?
        subregion = Region.create!(sr)
        RegionGroup.create!({region_id: subregion.id, super_region_id: region.id})
      end
    end
  end
end

# Permissions
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
  {token_type: 'plans', text_description: 'allows a user access to the plans api endpoint'}
]
token_permission_types.map{ |tpt| TokenPermissionType.create!(tpt) if TokenPermissionType.find_by(token_type: tpt[:token_type]).nil? }

# Create our generic organisation, a funder and a University
# -------------------------------------------------------
orgs = [
  {name: GlobalHelpers.constant("organisation_types.managing_organisation"),
   abbreviation: 'CC',
   banner_text: 'This is an example organisation',
   org_type: 3,
   language_id: Language.find_by(abbreviation: I18n.locale).id,
   token_permission_types: TokenPermissionType.all},
  {name: 'Government Agency',
   abbreviation: 'GA',
   org_type: 2,
   language_id: Language.find_by(abbreviation: I18n.locale).id},
  {name: 'University of Exampleland',
   abbreviation: 'UOS',
   org_type: 1,
   language_id: Language.find_by(abbreviation: I18n.locale).id}
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
   org: Org.find_by(abbreviation: 'CC'),
   language: Language.find_by(abbreviation: I18n.locale),
   perms: Perm.all,
   accept_terms: true,
   confirmed_at: Time.zone.now},
  {email: "funder_admin@example.com",
   firstname: "Funder",
   surname: "Admin",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: 'GA'),
   language: Language.find_by(abbreviation: I18n.locale),
   perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation']),
   accept_terms: true,
   confirmed_at: Time.zone.now},
  {email: "org_admin@example.com",
   firstname: "Organisational",
   surname: "Admin",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: 'UOS'),
   language: Language.find_by(abbreviation: I18n.locale),
   perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation']),
   accept_terms: true,
   confirmed_at: Time.zone.now},
  {email: "org_user@example.com",
   firstname: "Organisational",
   surname: "User",
   password: "password123",
   password_confirmation: "password123",
   org: Org.find_by(abbreviation: 'UOS'),
   language: Language.find_by(abbreviation: I18n.locale),
   accept_terms: true,
   confirmed_at: Time.zone.now}
]
users.map{ |u| User.create!(u) if User.find_by(email: u[:email]).nil? }

# Create a Guidance Group for our organisation and the funder
# ------------------------------------------------------- 
guidance_groups = [
  {name: "Generic Guidance (provided by the example curation centre)",
   org: Org.find_by(abbreviation: 'CC'),
   optional_subset: true},
  {name: "Government Agency Advice (Funder specific guidance)",
   org: Org.find_by(abbreviation: 'GA'),
   optional_subset: false}
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
   org: Org.find_by(abbreviation: 'CC'),
   is_default: true},
  {title: "Department of Testing Award",
   published: true,
   org: Org.find_by(abbreviation: 'GA'),
   is_default: false}
]
templates.map{ |t| Template.create!(t) if Template.find_by(title: t[:title]).nil? }

# Create 2 phases for the funder's template and one for our generic template
# ------------------------------------------------------- 
phases = [
  {title: "Generic DMP",
   number: 1,
   template: Template.find_by(title: "My Curation Center's Default Template"),
   modifiable: false},
   
  {title: "Preliminary Statement of Work",
   number: 1,
   template: Template.find_by(title: "Department of Testing Award"),
   modifiable: false},
  {title: "Detailed Overview",
   number: 2,
   template: Template.find_by(title: "Department of Testing Award"),
   modifiable: false}
]
phases.map{ |p| Phase.create!(p) if Phase.find_by(title: p[:title]).nil? }

generic_template_phase_1 = Phase.find_by(title: "Generic DMP")
funder_template_phase_1 = Phase.find_by(title: "Preliminary Statement of Work")
funder_template_phase_2 = Phase.find_by(title: "Detailed Overview")

# Create sections for the 2 templates and their phases
# ------------------------------------------------------- 
sections = [
  # Sections for the 'Generic DMP' phase of the 'My Curation Center's Default Template'
  {title: "Data Collection",
   number: 1,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Documentation and Metadata",
   number: 2,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Ethics and Legal Compliance",
   number: 3,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Storage and Backup",
   number: 4,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Selection and Preservation",
   number: 5,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Data Sharing",
   number: 5,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Responsibilities and Resources",
   number: 5,
   phase: generic_template_phase_1,
   published: true,
   modifiable: false},
     
  # Sections for the 'Preliminary Statement of Work' phase of the 'Department of Testing Award'
  {title: "Data Description",
   number: 1,
   phase: funder_template_phase_1,
   published: true,
   modifiable: false},
  {title: "Collection Methodology",
   number: 2,
   phase: funder_template_phase_1,
   published: true,
   modifiable: false},

  # Sections for the 'Detailed Overview' phase of the 'Department of Testing Award'
  {title: "Preservation Policy",
   number: 1,
   phase: funder_template_phase_2,
   published: true,
   modifiable: false},
  {title: "Data Format and Storage",
   number: 2,
   phase: funder_template_phase_2,
   published: true,
   modifiable: false},
  {title: "Collection Process",
   number: 3,
   phase: funder_template_phase_2,
   published: true,
   modifiable: false},
  {title: "Ethical Standards",
   number: 4,
   phase: funder_template_phase_2,
   published: true,
   modifiable: false},
  {title: "Preservation and Reuse Policies",
   number: 5,
   phase: funder_template_phase_2,
   published: true,
   modifiable: false}
]
sections.map{ |s| Section.create!(s) if Section.find_by(title: s[:title]).nil? }

text_area_format = QuestionFormat.find_by(title: 'Text area')

# Create questions for the 2 templates and their phases/sections
# ------------------------------------------------------- 
questions = [
  # Questions for the 'Generic DMP' phase of the 'My Curation Center's Default Template'
  {number: 1,
   text: "What data will you collect or create?",
   section: generic_template_phase_1.sections.find_by(number: 1),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "How will the data be collected or created?",
   section: generic_template_phase_1.sections.find_by(number: 1),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "What documentation and metadata will accompany the data?",
   section: generic_template_phase_1.sections.find_by(number: 2),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "How will you manage ethical issues?",
   section: generic_template_phase_1.sections.find_by(number: 3),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "How will you manage copyright and Intellectual Property Rights (IPR) issues?",
   section: generic_template_phase_1.sections.find_by(number: 3),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "How will the data be stored and backed up during the research?",
   section: generic_template_phase_1.sections.find_by(number: 4),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "How will you manage access and security?",
   section: generic_template_phase_1.sections.find_by(number: 4),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "Which data are of long-term value and should be retained, shared, and/or preserved?",
   section: generic_template_phase_1.sections.find_by(number: 5),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "What is the long-term preservation plan for the dataset?",
   section: generic_template_phase_1.sections.find_by(number: 5),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "How will you share the data?",
   section: generic_template_phase_1.sections.find_by(number: 6),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "Are any restrictions on data sharing required?",
   section: generic_template_phase_1.sections.find_by(number: 6),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "Who will be responsible for data management?",
   section: generic_template_phase_1.sections.find_by(number: 7),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "What resources will you require to deliver your plan?",
   section: generic_template_phase_1.sections.find_by(number: 7),
   question_format: text_area_format,
   modifiable: false},
    
  # Questions for the 'Preliminary Statement of Work' phase of the 'Department of Testing Award'
  {number: 1,
   text: "Please provide a description of the type(s) of data you plan to collect.",
   default_value: "Statistical data stored in csv files, images in the RAW format, etc.",
   section: funder_template_phase_1.sections.find_by(number: 1),
   question_format: text_area_format,
   modifiable: false},
  {number: 1,
   text: "Please describe your methods for gathering and storing the data.",
   section: funder_template_phase_1.sections.find_by(number: 2),
   question_format: text_area_format,
   modifiable: false},
   
  # Questions for the 'Detailed Overview' phase of the 'Department of Testing Award'
  {number: 1,
   text: "Please describe your departmental and institutional policies about preserving research data.",
   section: funder_template_phase_2.sections.find_by(number: 1),
   question_format: text_area_format,
   modifiable: false},
   
  {number: 1,
   text: "Please list all data formats you intend to collect and provide a description of the storage facilities you intend to use.",
   section: funder_template_phase_2.sections.find_by(number: 2),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "Will require store your data in your institution's repository?",
   section: funder_template_phase_2.sections.find_by(number: 2),
   question_format: QuestionFormat.find_by(title: 'Check box'),
   modifiable: false},
   
  {number: 1,
   text: "How will you go about collecting your data?",
   section: funder_template_phase_2.sections.find_by(number: 3),
   question_format: text_area_format,
   modifiable: false},
   
  {number: 1,
   text: "How will you ensure that your data does not contain sensitive information like personal email addresses, social security number, names, etc.",
   section: funder_template_phase_2.sections.find_by(number: 4),
   question_format: text_area_format,
   modifiable: false},
   
  {number: 1,
   text: "Please describe your overall plan for preservation and reuse.",
   default_value: "Enter your policy guidelines here ...",
   section: funder_template_phase_2.sections.find_by(number: 5),
   question_format: text_area_format,
   modifiable: false},
  {number: 2,
   text: "What type of license will you use?",
   section: funder_template_phase_2.sections.find_by(number: 5),
   question_format: QuestionFormat.find_by(title: 'Dropdown'),
   modifiable: false},
  {number: 3,
   text: "When will the data be made available to the public?",
   guidance: "The date can be approximate.",
   section: funder_template_phase_2.sections.find_by(number: 5),
   question_format: QuestionFormat.find_by(title: 'Date'),
   modifiable: false}
]
questions.map{ |s| Question.create!(s) if Question.find_by(text: s[:text]).nil? }


# Create some options for our dropdown question
# ------------------------------------------------------- 
license_question = Question.find_by(text: "What type of license will you use?")
license_question_options = [
  {question: license_question,
   text: "BSD",
   number: 1,
   is_default: false},
  {question: license_question,
   text: "GNU",
   number: 2,
   is_default: false},
  {question: license_question,
   text: "MIT",
   number: 3,
   is_default: true}
]
license_question_options.map{ |q| QuestionOption.create!(q) if QuestionOption.find_by(text: q[:text]).nil? }