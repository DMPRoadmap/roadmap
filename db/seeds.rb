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
  {title: "Multi select box"}
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
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Data Description')]},
  {text: "● Clearly note what format(s) your data will be in, e.g., plain text (.txt), comma-separated values (.csv), geo-referenced TIFF (.tif, .tfw). 
● Explain why you have chosen certain formats. Decisions may be based on staff expertise, a preference for open formats, the standards accepted by data centres or widespread usage within a given community. 
● Using standardised, interchangeable or open formats ensures the long-term usability of data; these are recommended for sharing and archiving.
● See <a href='https://www.ukdataservice.ac.uk/manage-data/format/recommended-formats' title='UK Data Service guidance on recommended formats'>UK Data Service guidance on recommended formats</a> or <a href='https://www.dataone.org/best-practices/document-and-store-data-using-stable-file-formats' title='DataONE Best Practices for file formats'>DataONE Best Practices for file formats</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Data Format')]},
  {text: "● Note what volume of data you will create in MB/GB/TB
● Consider the implications of data volumes in terms of storage, access and preservation. Do you need to include additional costs?
● Consider whether the scale of the data will pose challenges when sharing or transferring data between sites; if so, how will you address these challenges?",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Data Volume')]},
  {text: "● Outline how the data will be collected and processed. This should cover relevant standards or methods, quality assurance and data organisation. 
● Indicate how the data will be organised during the project, mentioning, e.g., naming conventions, version control and folder structures. Consistent, well-ordered research data will be easier to find, understand and reuse
● Explain how the consistency and quality of data collection will be controlled and documented. This may include processes such as calibration, repeat samples or measurements, standardised data capture, data entry validation, peer review of data or representation with controlled vocabularies. 
● See the <a href='https://www.dataone.org/best-practices/quality' title='DataOne Best Practices for data quality'>DataOne Best Practices for data quality</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Data Collection')]},
  {text: "● What metadata will be provided to help others identify and discover the data?
● Researchers are strongly encouraged to use community metadata standards where these are in place. The Research Data Alliance offers a <a href='http://rd-alliance.github.io/metadata-directory' title='Directory of Metadata Standards'>Directory of Metadata Standards</a>.
● Consider what other documentation is needed to enable reuse. This may include information on the methodology used to collect the data, analytical and procedural information, definitions of variables, units of measurement, any assumptions made, the format and file type of the data and software used to collect and/or process the data.
● Consider how you will capture this information and where it will be recorded, e.g., in a database with links to each item, in a ‘readme’ text file, in file headers, etc. ",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Metadata & Documentation')]},
  {text: "● Investigators carrying out research involving human participants should request consent to preserve and share the data. Do not just ask for permission to use the data in your study or make unnecessary promises to delete it at the end.
● Consider how you will protect the identity of participants, e.g., via anonymisation or using managed access procedures.
● Ethical issues may affect how you store and transfer data, who can see/use it and how long it is kept. You should demonstrate that you are aware of this and have planned accordingly.
● See <a href='https://www.ukdataservice.ac.uk/manage-data/legal-ethical/consent-data-sharing' title='UK Data Service guidance on consent for data sharing'>UK Data Service guidance on consent for data sharing</a>
● See <a href='http://www.icpsr.umich.edu/icpsrweb/content/datamanagement/confidentiality/index.html' title='ICPSR approach to confidentiality'>ICPSR approach to confidentiality</a> and Health Insurance Portability and Accountability Act <a href='https://privacyruleandresearch.nih.gov/' title='(HIPAA) regulations for health research'>(HIPAA) regulations for health research</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Ethics & Privacy')]},
  {text: "● State who will own the copyright and IPR of any new data that you will generate. For multi-partner projects, IPR ownership should be covered in the consortium agreement. 
● Outline any restrictions needed on data sharing, e.g., to protect proprietary or patentable data. 
● Explain how the data will be licensed for reuse. See the <a href='http://www.dcc.ac.uk/resources/how-guides/license-research-data' title='DCC guide on How to license research data'>DCC guide on How to license research data</a> and <a href='https://ufal.github.io/public-license-selector' title='EUDAT’s data and software licensing wizard'>EUDAT’s data and software licensing wizard</a>.",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Intellectual Property Rights')]},
  {text: "● Describe where the data will be stored and backed up during the course of research activities. This may vary if you are doing fieldwork or working across multiple sites so explain each procedure.
● Identify who will be responsible for backup and how often this will be performed. The use of robust, managed storage with automatic backup, for example, that provided by university IT teams, is preferable. Storing data on laptops, computer hard drives or external storage devices alone is very risky. 
● See <a href='https://www.ukdataservice.ac.uk/manage-data/store' title='UK Data Service Guidance on data storage'>UK Data Service Guidance on data storage</a> or <a href='https://www.dataone.org/best-practices/storage' title='DataONE Best Practices for storage'>DataONE Best Practices for storage</a>
● Also consider data security, particularly if your data is sensitive e.g., detailed personal data, politically sensitive information or trade secrets. Note the main risks and how these will be managed. 
● Identify any formal standards that you will comply with, e.g., ISO 27001. See the <a href='http://www.dcc.ac.uk/resources/briefing-papers/standards-watch-papers/information-security-management-iso-27000-iso-27k-s' title='DCC Briefing Paper on Information Security Management -ISO 27000'>DCC Briefing Paper on Information Security Management -ISO 27000</a> and <a href='https://www.ukdataservice.ac.uk/manage-data/store/security' title='UK Data Service guidance on data security'>UK Data Service guidance on data security</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Storage & Security')]},
  {text: "● How will you share the data e.g. deposit in a data repository, use a secure data service, handle data requests directly or use another mechanism? The methods used will depend on a number of factors such as the type, size, complexity and sensitivity of the data. 
● When will you make the data available? Research funders expect timely release. They typically allow embargoes but not prolonged exclusive use. 
● Who will be able to use your data? If you need to restricted access to certain communities or apply data sharing agreements, explain why. 
● Consider strategies to minimise restrictions on sharing. These may include anonymising or aggregating data, gaining participant consent for data sharing, gaining copyright permissions, and agreeing a limited embargo period.
● How might your data be reused in other contexts? Where there is potential for reuse, you should use standards and formats that facilitate this, and ensure that appropriate metadata is available online so your data can be discovered. Persistent identifiers should be applied so people can reliably and efficiently find your data. They also help you to track citations and reuse.",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Data Sharing')]},
  {text: "● Where will the data be deposited? If you do not propose to use an established repository, the data management plan should demonstrate that the data can be curated effectively beyond the lifetime of the grant.
● It helps to show that you have consulted with the repository to understand their policies and procedures, including any metadata standards.
● An international list of data repositories is available via <a href='http://www.re3data.org/' title='Re3data'>Re3data</a> and some universities or publishers provide lists of recommendations e.g. <a href='http://journals.plos.org/plosone/s/data-availability#loc-recommended-repositories' title='PLOS ONE recommended repositories'>PLOS ONE recommended repositories</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Data Repository')]},
  {text: "● Indicate which data are of long-term value and should be shared and/or preserved.
● Outline the plans for data sharing and preservation - how long will the data be retained and where will it be archived?
● Will additional resources be needed to prepare data for deposit or meet any charges from data repositories? See the DCC guide: <a href='http://www.dcc.ac.uk/resources/how-guides/appraise-select-data' title='How to appraise and select research data for curation'>How to appraise and select research data for curation</a> or DataONE Best Practices: <a href='https://www.dataone.org/best-practices/identify-data-long-term-value' title='Identifying data with long-term value'>Identifying data with long-term value</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Preservation')]},
  {text: "● Outline the roles and responsibilities for all activities, e.g., data capture, metadata production, data quality, storage and backup, data archiving & data sharing. Individuals should be named where possible. 
● For collaborative projects you should explain the coordination of data management responsibilities across partners.
● See UK Data Service guidance on <a href='https://www.ukdataservice.ac.uk/manage-data/plan/roles-and-responsibilities' title='data management roles and responsibilities'>data management roles and responsibilities</a> or DataONE Best Practices: <a href='https://www.dataone.org/best-practices/define-roles-and-assign-responsibilities-data-management' title='Define roles and assign responsibilities for data management'>Define roles and assign responsibilities for data management</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Roles & Responsibilities')]},
  {text: "● Carefully consider and justify any resources needed to deliver the plan.  These may include storage costs, hardware, staff time, costs of preparing data for deposit and repository charges.
● Outline any relevant technical expertise, support and training that is likely to be required and how it will be acquired. 
● If you are not depositing in a data repository, ensure you have appropriate resources and systems in place to share and preserve the data. See UK Data Service guidance on <a href='https://www.ukdataservice.ac.uk/manage-data/plan/costing' title='costing data management'>costing data management</a>",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Budget')]},
  {text: "● Consider whether there are any existing procedures that you can base your approach on. If your group/department has local guidelines that you work to, point to them here. 
● List any other relevant funder, institutional, departmental or group policies on data management, data sharing and data security. ",
   guidance_groups: [GuidanceGroup.first],
   published: true,
   themes: [Theme.find_by(title: 'Related Policies')]},
  {text: "Please tell us how much data you plan to collect and what format it will be in once its deposited.",
   guidance_groups: [GuidanceGroup.last],
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
  {title: "Generic Data Management Planning Template",
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

# Create sections for the 2 templates and their phases
# ------------------------------------------------------- 
sections = [
  {title: "Overview",
   number: 1,
   phase: Phase.find_by(title: "Regional CurationCenter Data Management Plan"),
   published: true,
   modifiable: false},
  {title: "Collection",
   number: 2,
   phase: Phase.find_by(title: "Regional CurationCenter Data Management Plan"),
   published: true,
   modifiable: false},
  {title: "Documentation",
   number: 3,
   phase: Phase.find_by(title: "Regional CurationCenter Data Management Plan"),
   published: true,
   modifiable: false},
  {title: "Sharing and Usage",
   number: 4,
   phase: Phase.find_by(title: "Regional CurationCenter Data Management Plan"),
   published: true,
   modifiable: false},
  {title: "Long Term Preservation",
   number: 5,
   phase: Phase.find_by(title: "Regional CurationCenter Data Management Plan"),
   published: true,
   modifiable: false},

  {title: "Data Description",
   number: 1,
   phase: Phase.find_by(title: "Preliminary Statement of Work"),
   published: true,
   modifiable: false},
  {title: "Data Description",
   number: 1,
   phase: Phase.find_by(title: "Preliminary Statement of Work"),
   published: true,
   modifiable: false},

  {title: "Preservation Policy",
   number: 1,
   phase: Phase.find_by(title: "Detailed Overview"),
   published: true,
   modifiable: false},
  {title: "Data Format and Storage",
   number: 1,
   phase: Phase.find_by(title: "Detailed Overview"),
   published: true,
   modifiable: false},
  {title: "Collection Process",
   number: 1,
   phase: Phase.find_by(title: "Detailed Overview"),
   published: true,
   modifiable: false},
  {title: "Ethical Standards",
   number: 1,
   phase: Phase.find_by(title: "Detailed Overview"),
   published: true,
   modifiable: false},
  {title: "Preservation and Reuse Policies",
   number: 1,
   phase: Phase.find_by(title: "Detailed Overview"),
   published: true,
   modifiable: false}
]
sections.map{ |s| Section.create!(s) if Section.find_by(title: s[:title]).nil? }


=begin
 questions = {
   "What data will you collect or create?" => {
     text: "What data will you collect or create?",
     section: "Data Collection",
     number: 1,
     guidance: "<p class='guidance_header'>Questions to consider:</p> <ul> <li>What type, format and volume of data?</li> <li>Do your chosen formats and software enable sharing and long-term access to the data?</li> <li>Are there any existing data that you can reuse?</li> </ul> <p class='guidance_header'>Guidance:</p> <p>Give a brief description of the data, including any existing data or third-party sources that will be used, in each case noting its content, type and coverage. Outline and justify your choice of format and consider the implications of data format and data volumes in terms of storage, backup and access.</p>",
     themes: ["Theme 2"]
   },
   "How will the data be collected or created?" => {
     text: "How will the data be collected or created?",
     section: "Data Collection",
     number: 2,
     guidance: "<p class='guidance_header'>Questions to consider:</p> <ul> <li>What standards or methodologies will you use?</li> <li>How will you structure and name your folders and files?</li> <li>How will you handle versioning?</li> <li>What quality assurance processes will you adopt?</li> </ul> <p class='guidance_header'>Guidance:</p> <p>Outline how the data will be collected/created and which community data standards (if any) will be used. Consider how the data will be organised during the project, mentioning for example naming conventions, version control and folder structures. Explain how the consistency and quality of data collection will be controlled and documented. This may include processes such as calibration, repeat samples or measurements, standardised data capture or recording, data entry validation, peer review of data or representation with controlled vocabularies.</p>",
     themes: ["Theme 3"]
   },
   "What documentation and metadata will accompany the data?" => {
     text: "What documentation and metadata will accompany the data?",
     section: "Documentation and Metadata",
     number: 1,
     guidance: "<p class='guidance_header'>Questions to consider:</p> <ul> <li>What information is needed for the data to be to be read and interpreted in the future?</li> <li>How will you capture / create this documentation and metadata?</li> <li>What metadata standards will you use and why?</li> </ul> <p class='guidance_header'>Guidance:</p> <p>Describe the types of documentation that will accompany the data to help secondary users to understand and reuse it. This should at least include basic details that will help people to find the data, including who created or contributed to the data, its title, date of creation and under what conditions it can be accessed.</p> <p>Documentation may also include details on the methodology used, analytical and procedural information, definitions of variables, vocabularies, units of measurement, any assumptions made, and the format and file type of the data. Consider how you will capture this information and where it will be recorded. Wherever possible you should identify and use existing community standards.</p>",
     themes: ["Theme 1"]
   },
   "Data Overview" => {
     text: "Overview of the Data",
     section: "Data Overview",
     number: 1,
     guidance: "<p class='guidance_header'>Things to consider:</p> <ul> <li>What type(s) of data will you collect?</li> <li>Will you need special software/tools to access the data?</li><li>How do you plan to store your data?</li></p>",
     themes: ["Theme 4"]
   },
   "Data Overview" => {
     text: "Overview of the Data",
     section: "Data Overview",
     number: 1,
     guidance: "<p class='guidance_header'>Things to consider:</p> <ul> <li>What type(s) of data will you collect?</li> <li>Will you need special software/tools to access the data?</li><li>How do you plan to store your data?</li></p>",
     themes: ["Theme 4"]
   },
   "How will you manage any ethical issues?" => {
     text: "How will you manage any ethical issues?",
     section: "Ethics and Legal Compliance",
     number: 1,
     guidance: "<p class='guidance_header'>Questions to consider:</p> <ul> <li>Have you gained consent for data preservation and sharing?</li> <li>How will you protect the identity of participants if required? e.g. via anonymisation</li> <li>How will sensitive data be handled to ensure it is stored and transferred securely?</li> </ul> <p class='guidance_header'>Guidance:</p> <p>Ethical issues affect how you store data, who can see/use it and how long it is kept. Managing ethical concerns may include: anonymisation of data; referral to departmental or institutional ethics committees; and formal consent agreements. You should show that you are aware of any issues and have planned accordingly. If you are carrying out research involving human participants, you must also ensure that consent is requested to allow data to be shared and reused.</p>",
     themes: ["Theme 4"]
   },
   "How will you manage copyright and Intellectual Property Rights (IPR) issues?" => {
     text: "How will you manage copyright and Intellectual Property Rights (IPR) issues?",
     section: "Ethics and Legal Compliance",
     number: 2,
     guidance: "<p class='guidance_header'>Questions to consider:</p> <ul> <li>Who owns the data?</li> <li>How will the data be licensed for reuse?</li> <li>Are there any restrictions on the reuse of third-party data?</li> <li>Will data sharing be postponed / restricted e.g. to publish or seek patents?</li> </ul> <p class='guidance_header'>Guidance:</p> <p>State who will own the copyright and IPR of any data that you will collect or create, along with the licence(s) for its use and reuse. For multi-partner projects, IPR ownership may be worth covering in a consortium agreement. Consider any relevant funder, institutional, departmental or group policies on copyright or IPR. Also consider permissions to reuse third-party data and any restrictions needed on data sharing.</p>",
     themes: ["Theme 1"]
   },
   "How will the data be stored and backed up during the research?" => {
     text: "How will the data be stored and backed up during the research?",
     section: "Storage and Backup",
     number: 1,
     guidance: "<p class='guidance_header'>Questions to consider:</p> <ul> <li>Do you have sufficient storage or will you need to include charges for additional services?</li> <li>How will the data be backed up?</li> <li>Who will be responsible for backup and recovery?</li> <li>How will the data be recovered in the event of an incident?</li> </ul> <p class='guidance_header'>Guidance: </p> <p>State how often the data will be backed up and to which locations. How many copies are being made? Storing data on laptops, computer hard drives or external storage devices alone is very risky. The use of robust, managed storage provided by university IT teams is preferable. Similarly, it is normally better to use automatic backup services provided by IT Services than rely on manual processes. If you choose to use a third-party service, you should ensure that this does not conflict with any funder, institutional, departmental or group policies, for example in terms of the legal jurisdiction in which data are held or the protection of sensitive data.</p>",
     themes: ["Theme 2"]
   },
   "4a: Preserving Your Data" => {
     text: "4a: Preserving Your Data",
     section: "Preservation, Sustainability and Use",
     number: 1,
     guidance: "<p>Preservation of digital outputs is necessary in order for them to endure changes in the technological environment and remain potentially re-usable in the future. In this section you must state what, if any, digital outputs of your project you intend to preserve beyond the period of funding.</p><p>The length and cost of preservation should be proportionate to the value and significance of the digital outputs. If you believe that none of these should be preserved this must be justified, and if the case is a good one the application will not be prejudiced.</p><p>You must consider preservation in four ways: what, where, how and for how long. You must also consider any institutional support needed in order to carry out these plans, whether from an individual, facility, organisation or service.</p><p>You should think about the possibilities for re-use of your data in other contexts and by other users, and connect this as appropriate with your plans for dissemination and Pathways to Impact.Where there is potential for re-usability, you should use standards and formats that facilitate this.</p><p>The Technical Reviewer will be looking for evidence that you understand the reasons for the choice of technical standards and formats described in Section 2.a Technical Methodology: Standards and Formats.</p><p>You should describe the types of documentation which will accompany the data. Documentation in this sense means technical documentation as well as user documentation. It includes, for instance, technical description, code commenting, project-build guidelines, the documentation of technical decisions and resource metadata which is additional to the standards which you have described in Section 2.a. Not all types of documentation will be relevant to a project and the quantity of documentation proposed should be proportionate to the envisaged value of the data.</p>",
     themes: ["Theme 2", "Theme 3", "Theme 4"]
   },
   "4b: Ensuring Continued Accessibility and Use of Your Digital Outputs" => {
     text: "4b: Ensuring Continued Accessibility and Use of Your Digital Outputs",
     section: "Preservation, Sustainability and Use",
     number: 2,
     guidance: "<p>In this section you must provide information about any plans for ensuring that digital outputs remain sustainable in the sense of immediately accessible and usable beyond the period of funding. There are costs to ensuring sustainability in this sense over and above the costs of preservation. The project's sustainability plan should therefore be proportionate to the envisaged longer-term value of the data for the research community and should be closely related to your plans for dissemination and Pathways to Impact.</p><p>If you believe that digital outputs should not be sustained beyond the period of funding then this should be justified. It is not mandatory to sustain all digital outputs. While you should consider the long-term value of the digital outputs to the research community, where they are purely ancillary to a project’s research outputs there may not be a case for sustaining them (though there would usually be a case for preservation).</p><p>You must consider the sustainability of your digital outputs in five ways: what, where, how, for how long, and how the cost will be covered. You must make appropriate provision for user consultation and user testing in this connection, and plan the development of suitable user documentation.</p><p>You should provide justification if you do not envisage open, public access. A case can be made for charging for or otherwise limiting access, but the default expectation is that access will be open. The Technical Reviewer will be looking for realistic commitments to sustaining public access in line with affordability and the longer-term value of the digital output.</p><p>You must consider any institutional support needed in order to carry out these plans, if not covered under Section 3, as well as the cost of keeping the digital output publicly available in the future, including issues relating to maintenance, infrastructure and upgrade (such as the need to modify aspects of a web interface or software application in order to account for changes in the technological environment). In order to minimise sustainability costs, it is generally useful that the expertise involved in the development of your project is supported by expertise in your own or a partner institution.</p><p>A sustainability plan does not necessarily mean a requirement to generate income or prevent resources from being freely available. Rather it is a requirement to consider the direct costs and expertise of maintaining digital outputs for continued access. Some applicants might be able to demonstrate that there will be no significant sustainability problems with their digital output; in some cases the university’s computing services or library might provide a firm commitment to sustaining the resource for a specified period; others might see the benefit of Open Source community development models. You should provide reassurances of sustainability which are proportionate to the envisaged longer-term value of the digital outputs for the research community.</p><p>When completing this section, you should consider the potential impact of the data on research in your field (if research in the discipline will be improved through the creation of the digital output, how will it be affected if the resource then disappears?), and make the necessary connections with your Impact Plan. You must factor in the effects of any IP, copyright and ethical issues during the period in which the digital output will be publicly accessible, connecting what you say with the relevant part of your Case for Support.</p><p>You must identify whether or not you envisage the academic content (as distinct from the technology) of the digital output being extended or updated beyond the period of funding, addressing the following issues: how this will be done, by who and at what cost. You will need to show how the cost of this will be sustained after the period of funding ends.</p>",
     themes: ["Theme 2"]
   }
 }

 questions.each do |q, details|
   if Question.where(text: details[:text]).empty?
     question = Question.new
     question.text = details[:text]
     question.number = details[:number]
     question.guidance = details[:guidance]
     question.section = Section.find_by_title(details[:section])
     details[:themes].each do |theme|
       question.themes << Theme.find_by_title(theme)
     end
     question.save!
   end
 end

formatting = {
    'Funder' => {
        font_face: "Arial, Helvetica, Sans-Serif",
        font_size: 11,
        margin: { top: 20, bottom: 20, left: 20, right: 20 }
    },
    'DCC' => {
        font_face: "Arial, Helvetica, Sans-Serif",
        font_size: 12,
        margin: { top: 20, bottom: 20, left: 20, right: 20 }
    }
}

formatting.each do |org, settings|
  #template = Dmptemplate.find_by_title("#{org} Template") # this is bugged, there is no Funder Template nor DCC template
  #template.settings(:export).formatting = settings
  #template.save!
end

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
=end