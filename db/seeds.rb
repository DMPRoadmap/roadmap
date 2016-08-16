# -*- coding: utf-8 -*-
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Dmptemplate default formatting settings based on https://je-s.rcuk.ac.uk/Handbook/pages/GuidanceonCompletingaStandardG/CaseforSupportandAttachments/CaseforSupportandAttachments.htm

d1 = DateTime.new(2015, 6, 22)

languages = {
    'English(UK)' => {
        abbreviation: 'en-UK',
        description: 'UK English language used as default',
        name: 'English(UK)',
        default_language: true
    },
    'FR' => {
        abbreviation: 'fr',
        description: '',
        name: 'fr',
        default_language: false
    },
    'DE' => {
        abbreviation: 'de',
        description: '',
        name: 'de',
        default_language: false
    }
}

languages.each do |l, details|
  language = Language.new
  language.abbreviation = details[:abbreviation]
  language.description = details[:description]
  language.name = details[:name]
  language.default_language = details[:default_language]
  language.save!
end

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
  region = Region.new
  region.abbreviation = details[:abbreviation]
  region.description = details[:description]
  region.name = details[:name]
  region.save!
end

region_groups = {
    'UK' => {
        super_region_name: 'Horizon2020',
        region_name: 'UK',
    },
    'DE' => {
        super_region_name: 'Horizon2020',
        region_name: 'DE',
    }
}

region_groups.each do |l, details|
  region_group = RegionGroup.new
  region_group.super_region_id = Region.find_by_name(details[:super_region_name]).id
  region_group.region_id = Region.find_by_name(details[:region_name]).id
  region_group.save!
end

organisation_types = {
 'Organisation' => {
     name: "Organisation"
   },
   'Funder' => {
     name: "Funder"
   },
   'Project' => {
     name: "Project"
   },
   'Institution' => {
     name: "Institution"
   },
   'Research Institute' => {
     name: "Research Institute"
   }
 }

 organisation_types.each do |org_type, details|
   if OrganisationType.where(name: details[:name]).empty?
     organisation_type = OrganisationType.new
     organisation_type.name = details[:name]
     organisation_type.save!
   end
 end

 organisations = {
   'Your Organization' => {
     name: "My Regional Curation Centre",
     abbreviation: "RCC",
     sort_name: "MyRegionalCurationCenter",
     organisation_type: "Organisation",
     description: "An example: Regional Curation Center concerned with research data management (typically the organization hosting this website)",
     banner_text: "Example: Your Regional Curation Center",
     domain: "example.regionalcurationcenter.org",
     region: 'UK',
     language: 'English(UK)'
   },
   'Global Funding Organization' => {
     name: "Global Research Center",
     abbreviation: "EGRC",
     sort_name: "GlobalResearchCenter",
     organisation_type: "Funder",
     description: "An example: Research funding agency",
     banner_text: "Example: Global Research Center",
     domain: "example.globalresearchcenter.org",
     region: 'UK',
     language: 'English(UK)'
   },
   'Regional Funding Organization' => {
     name: "Regional Science Federation",
     abbreviation: "RegSciFed",
     sort_name: "RegionalScienceFederation",
     organisation_type: "Funder",
     description: "An example: Regional funding agency for scientific research",
     banner_text: "Example: Regional Science Federation",
     domain: "example.regionalsciencefederation.org",
     region: 'UK',
     language: 'English(UK)'
   },
   'Example Institution'=> {
     name: "Capital City College",
     abbreviation: "CapColl",
     domain: "example.capitalcitycollege.edu",
     sort_name: "CapitalCityCollege",
     organisation_type: "Institution",
     description: "An example: Academic institution",
     banner_text: "Example: Capital City College ... go mascots!!",
     region: 'UK',
     language: 'English(UK)'
   }
 }

 organisations.each do |org, details|
   if Organisation.where(abbreviation: details[:abbreviation]).empty?
     organisation = Organisation.new
     organisation.name = details[:name]
     organisation.abbreviation = details[:abbreviation]
     organisation.domain = details[:domain]
     organisation.sort_name = details[:sort_name]
     organisation.organisation_type = OrganisationType.find_by_name(details[:organisation_type])
     organisation.region_id = Region.find_by_name(details[:region]).id
     organisation.language_id = Language.find_by_name(details[:language]).id
     organisation.save!
   end
 end

roles = {
  'admin' => {
    name: "admin"
  },
  'org_admin' => {
    name: "org_admin"
  },
  'user' => {
    name: "user"
  }
}

roles.each do |role, details|
  if Role.where(name: details[:name]).empty?
    role = Role.new
    role.name = details[:name]
    role.save!
  end
end

user_role_types = {
  'admin' => {
    name: 'admin'
  },
  'org_admin' => {
    name: 'org_admin'
  },
  'user' => {
    name: 'user'
  }
}

user_role_types.each do |urt, details|
  if UserRoleType.where(name: details[:name]).empty?
    UserRoleType.create(name: details[:name])
  end
end

users = {
    'Super admin' => {
        email: "super_admin@example.com",
        password: "password123",
        firstname: "RCC Super",
        surname: "Admin",
        password_confirmation: "password123",
        organisation: "RCC",
        language: 'English(UK)',
        roles: ['admin','org_admin'],
        accept_terms: true,
        confirmed_at: Time.zone.now
    },
    'Funder admin' => {
        email: "funder_admin@example.com",
        password: "password123",
        password_confirmation: "password123",
        firstname: "Funder",
        surname: "Admin",
        organisation: "RegSciFed",
        language: 'English(UK)',
        roles: ['org_admin'],
        accept_terms: true,
        confirmed_at: Time.zone.now
    },
    'Organizational admin' => {
        email: "org_admin@example.com",
        password: "password123",
        password_confirmation: "password123",
        firstname: "Organization",
        surname: "Admin",
        organisation: "CapColl",
        language: 'English(UK)',
        roles: ['org_admin'],
        accept_terms: true,
        confirmed_at: Time.zone.now
    },
    'Organizational user' => {
        email: "org_user@example.com",
        password: "password123",
        password_confirmation: "password123",
        firstname: "Jane",
        surname: "Researcher",
        organisation: "CapColl",
        language: 'English(UK)',
        roles: ['user'],
        accept_terms: true,
        confirmed_at: Time.zone.now
    }
 }
 
users.each do |user, details|
  if User.where(email: details[:email]).empty?
    usr = User.new
    usr.email = details[:email]
    usr.password = details[:password]
    usr.password_confirmation = details[:password_confirmation]
    usr.confirmed_at = details[:confirmed_at]
    usr.organisation_id = Organisation.find_by_abbreviation(details[:organisation]).id
#    usr.user_org_roles << UserOrgRole.create(organisation: Organisation.find_by_abbreviation(details[:organisation]),
#                                             user_role_type: UserRoleType.find_by_name('admin'))
    usr.language_id = Language.find_by_name(details[:language]).id
    details[:roles].each do |role|
     usr.roles << Role.find_by_name(role)
    end
    usr.accept_terms = details[:accept_terms]
    
    usr.save!
  end
end

 themes = {
   "Theme 1" => {
     title: "Theme 1",
     locale: "en"
   },
   "Theme 2" => {
     title: "Theme 2",
     locale: "en"
   },
   "Theme 3" => {
     title: "Theme 3",
     locale: "en",
     description: "Theme 3 description."
   },
   "Theme 4" => {
     title: "Theme 4",
     locale: "en",
     description: "Theme 4 description."
   }
 }

 themes.each do |t, details|
   if Theme.where(title: details[:title]).empty?
     theme = Theme.new
     theme.title = details[:title]
     theme.locale = details[:locale]
     theme.description = details[:description]
     theme.save!
   end
 end

 question_formats = {
   "Text area" => {
     title: "Text area"
   },
   "Text field" => {
     title: "Text field"
   },
   "Radio buttons" => {
     title: "Radio buttons"
   },
   "Check box" => {
     title: "Check box"
   },
   "Dropdown" => {
     title: "Dropdown"
   },
   "Multi select box" => {
     title: "Multi select box"
   },
 }

 question_formats.each do |qf, details|
   if QuestionFormat.where(title: details[:title]).empty?
     question_format = QuestionFormat.new
     question_format.title = details[:title]
     question_format.save!
   end
 end

 guidance_groups = {
   "RCC Guidance" => {
     name: "My organization guidance (optional generic guidance you provide for users)",
     organisation: "RCC",
     optional_subset: true
   },
   "Global Research Center Guidance" => {
     name: "Global Research Center (Funder specific guidance)",
     organisation: "EGRC",
     optional_subset: false
   },
   "Regional Science Federation Guidance" => {
     name: "Regional Science Federation (Funder specific guidance)",
     organisation: "RegSciFed",
     optional_subset: false
   },
   "Institutional Guidance" => {
     name: "CapColl - School of Math and Science (optional institutional guidance)",
     organisation: "CapColl",
     optional_subset: true
   }
 }

 guidance_groups.each do |gg, details|
   if GuidanceGroup.where(name: details[:name]).empty?
     guidance_group = GuidanceGroup.new
     guidance_group.name = details[:name]
     guidance_group.organisation = Organisation.find_by_abbreviation(details[:organisation])
     guidance_group.optional_subset = details[:optional_subset]
     guidance_group.save!
   end
 end

 guidances = {
   "Guidance 1" => {
     text: "Guidance text",
     guidance_group: "My organization guidance (optional generic guidance you provide for users)",
     themes: ["Theme 4"]
   },
   "Guidance 2" => {
     text: "Guidance text",
     guidance_group: "Global Research Center (Funder specific guidance)",
     themes: ["Theme 2"]
   },
   "Guidance 3" => {
     text: "Guidance text",
     guidance_group: "Global Research Center (Funder specific guidance)",
     themes: ["Theme 3"]
   },
   "Guidance 4" => {
     text: "Guidance text",
     guidance_group: "Regional Science Federation (Funder specific guidance)",
     themes: ["Theme 1"]
   },
   "Guidance 4" => {
     text: "Guidance text",
     guidance_group: "CapColl - School of Math and Science (optional institutional guidance)",
     themes: ["Theme 1"]
   }
 }

 guidances.each do |g, details|
   if Guidance.where(text: details[:text]).empty?
     guidance = Guidance.new
     guidance.text = details[:text]
     guidance.guidance_groups << GuidanceGroup.find_by_name(details[:guidance_group])
     details[:themes].each do |theme|
       guidance.themes << Theme.find_by_title(theme)
     end
     guidance.save!
   end
 end

 templates = {
   "RCC" => {
     title: "Regional Curation Center Template",
     description: "The default RCC template",
     published: true,
     organisation: "RCC",
     locale: "en",
     is_default: true
   },
   "Global Research Center" => {
     title: "Global Research Center Award",
     description: "Funder template description",
     published: true,
     organisation: "EGRC",
     locale: "en",
     is_default: false
   },
   "Regional Science Federation" => {
     title: "Regional Science Federation Grant - Summary",
     description: "Funder template description for phase 1",
     published: true,
     organisation: "RegSciFed",
     locale: "en",
     is_default: false
   },
   "Regional Science Federation2" => {
     title: "Regional Science Federation Grant - Finalized",
     description: "Funder template description for phase 2",
     published: true,
     organisation: "RegSciFed",
     locale: "en",
     is_default: false
   }
 }

 templates.each do |t, details|
   org = Organisation.where(abbreviation: details[:organisation]).first
   
   if Dmptemplate.where(organisation: org).where(title: details[:title]).empty?
     template = Dmptemplate.new
     template.title = details[:title]
     template.description = details[:description]
     template.published = details[:published]
     template.locale = details[:locale]
     template.is_default = details[:is_default]
     template.organisation = org
     template.save!
   end
 end

 phases = {
   "RCC" => {
     title: "Regional CurationCenter Data Management Plan",
     number: 1,
     template: "Regional Curation Center Template"
   },
   "EGRC Template" => {
     title: "Global Research Center Annual Award",
     number: 1,
     template: "Global Research Center Award"
   },
   "RegSciFed Template" => {
     title: "Regional Science Federation - Preliminary",
     number: 1,
     template: "Regional Science Federation Grant - Summary"
   },
   "RegSciFed Template2" => {
     title: "Regional Science Federation - Final",
     number: 1,
     template: "Regional Science Federation Grant - Finalized"
   }
 }

 phases.each do |p, details|
   if Phase.where(title: details[:title]).empty?
     phase = Phase.new
     phase.title = details[:title]
     phase.number = details[:number]
     phase.dmptemplate = Dmptemplate.find_by_title(details[:template])
     phase.save!
   end
 end

 versions = {
   "RCC" => {
     title: "Default Template v1",
     number: 1,
     phase: "Regional CurationCenter Data Management Plan"
   },
   "EGRC" => {
     title: "Annual Award v1",
     number: 1,
     phase: "Global Research Center Annual Award"
   },
   "RegSciFed_1" => {
     title: "Grant Summary v1",
     number: 1,
     phase: "Regional Science Federation - Preliminary"
   },
   "RegSciFed_2" => {
     title: "Grant Finalized Award v1",
     number: 1,
     phase: "Regional Science Federation - Final"
   },
   "RegSciFed_2.1" => {
     title: "Grant Finalized v2",
     number: 1,
     phase: "Regional Science Federation - Final"
   },
 }

 versions.each do |v, details|
   if Version.where(title: details[:title]).empty?
     version = Version.new
     version.title = details[:title]
     version.number = details[:number]
     version.phase = Phase.find_by_title(details[:phase])
     version.save!
   end
 end

 sections = {
   "Section 1" => {
     title: "Data Collection",
     number: 1,
     description: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
     version: "Default Template v1",
     organisation: "RCC"
   },
   "Section 2" => {
     title: "Documentation and Metadata",
     number: 2,
     description: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
     version: "Default Template v1",
     organisation: "RCC"
   },
   "Section A" => {
     title: "Data Overview",
     number: 1,
     version: "Annual Award v1",
     organisation: "EGRC"
   },
   "Section B" => {
     title: "Ethics and Legal Compliance",
     number: 2,
     version: "Annual Award v1",
     organisation: "EGRC"
   },
   "Section C" => {
     title: "Storage and Backup",
     number: 3,
     version: "Annual Award v1",
     organisation: "EGRC"
   },
   "Section D" => {
     title: "Preservation, Sustainability and Use",
     number: 4,
     version: "Annual Award v1",
     organisation: "EGRC"
   },
   "regSciFed Summary" => {
     title: "Data Collection Guidelines",
     number: 1,
     description: "This is what we plan on collecting and how we're going to store it.",
     version: "Grant Summary v1",
     organisation: "RegSciFed"
   },
   "RegSciFed Final 1" => {
     title: "Data Collection and Storage",
     number: 1,
     version: "Grant Finalized Award v1",
     organisation: "RegSciFed"
   },
   "RegSciFed Final 1_2" => {
     title: "Data Preservation",
     number: 2,
     version: "Grant Finalized v2",
     organisation: "RegSciFed"
   },
   "RegSciFed Final 2_2" => {
     title: "Ongoing Access",
     number: 3,
     version: "Grant Finalized v2",
     organisation: "RegSciFed"
   }
 }

 sections.each do |s, details|
   if Section.where(title: details[:title]).empty?
     section = Section.new
     section.title = details[:title]
     section.number = details[:number]
     section.description = details[:description]
     section.version = Version.find_by_title(details[:version])
     section.organisation = Organisation.find_by_abbreviation(details[:organisation])
     section.save!
   end
 end

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
  token_permission_type = TokenPermissionType.new
  token_permission_type.token_type = title
  token_permission_type.text_desription = settings[:description]
  token_permission_type.save!
end

languages = {
  'en-UK': {
    abbreviation: 'en-UK', name: 'en-UK', description: 'English - UK', default_language: 0
  },
  'en-US': {
    abbreviation: 'en-US', name: 'en-US', description: 'English - US', default_language: 1
  },
  'fr': {
    abbreviation: 'fr', name: 'fr', description: 'French', default_language: 0
  },
  'de': {
    abbreviation: 'de', name: 'de', description: 'German', default_language: 0
  }
}

languages.each do |title,settings|
  Language.new(settings).save!
end
