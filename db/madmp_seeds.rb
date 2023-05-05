#!/usr/bin/env ruby
# frozen_string_literal: true

# warn_indent: true

# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Question Formats
# -------------------------------------------------------
question_formats = [
  {
    title: "Structured",
    description: "Structured",
    option_based: false,
    formattype: 7,
    structured: true
  }
]

question_formats.each { |qf| QuestionFormat.create!(qf) if QuestionFormat.find_by(title: qf[:title]).nil? }

# Create our generic organisation, a funder and a University
# -------------------------------------------------------
orgs = [
  {
    name: "Science Europe",
    abbreviation: "Science Europe",
    org_type: 1, links: { "org": [] },
    language: Language.find_by(abbreviation: "fr-FR")
  }
]

orgs.each { |o| Org.create!(o) if Org.find_by(name: o[:name]).nil? }

# Create a default template for the curation centre and one for the example funder
# -------------------------------------------------------
templates = [
  {
    title: "Science Europe : modèle structuré",
    published: true,
    org: Org.find_by(abbreviation: "Science Europe"),
    locale: "fr-FR",
    is_default: true,
    version: 0,
    visibility: Template.visibilities[:organisationally_visible],
    links: { "funder": [], "sample_plan": [] },
    description: <<-DESCRIPTION
      <p>Modèle structuré&nbsp; de plan de gestion de données (PGD) basé sur le "<a href="https://www.ouvrirlascience.fr/science-europe-guide-pratique-pour-une-harmonisation-internationale-de-la-gestion-des-donnees-de-recherche-v2/" target="_blank" class="has-new-window-popup-info">Guide pratique pour une harmonisation internationale de la gestion des données de recherche-V2<span class="new-window-popup-info">Ouvre une nouvelle fenêtre</span></a>" (janvier 2021) de Science Europe. Organisé en 12 questions, il couvre les six exigences fondamentales pour une bonne gestion et le partage des données dans le respect des principes FAIR*.&nbsp;</p>
      <p>L’objectif de ce modèle est de rendre le contenu du PGD à la fois lisible par les humains et exploitable par les machines, afin de proposer de nouveaux services ou améliorer certains services existants.</p>
      <p>Le modèle structuré&nbsp;:</p>
      <ul>
        <li>facilite la <strong>réutilisation automatique d’informations</strong> (projets ANR),</li>
        <li>encourage l’<strong>utilisation d’identifiants</strong> (contributeurs, organisations, partenaires…),</li>
        <li>propose des <strong>référentiels</strong> (standards de métadonnées, entrepôts de données, terminologies…),</li>
        <li>permet d’identifier et de lister les types de <strong>coûts associés à la gestion des données</strong>,</li>
        <li>simplifie et automatise les <strong>échanges d’informations</strong> avec les services impliqués dans la gestion des données (centre de stockage par exemple),</li>
        <li>produit un <strong>format de PGD</strong> <strong>conforme aux <a href="https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard" target="_blank" class="has-new-window-popup-info">recommandations RDA<span class="new-window-popup-info">Ouvre une nouvelle fenêtre</span></a></strong>.</li>
      </ul>
      <p>Des recommandations sont proposées pour aider les chercheurs à renseigner ce modèle et à s'assurer que tous les aspects pertinents de la gestion des données sont effectivement couverts.</p>
      <p><em>*</em> <em>Acronyme pour Facile à trouver, Accessible, Interopérable, Réutilisable.</em></p>
    DESCRIPTION
  },
  {
    title: "Science Europe: structured template",
    published: true,
    org: Org.find_by(abbreviation: "Science Europe"),
    locale: "en-GB",
    is_default: false,
    version: 0,
    visibility: Template.visibilities[:organisationally_visible],
    links: { "funder": [], "sample_plan": [] },
    description: <<-DESCRIPTION
      <p>Structured template for a Data Management Plan (DMP) based on Science Europe's "<a href="https://www.scienceeurope.org/our-resources/practical-guide-to-the-international-alignment-of-research-data-management/" target="_blank" class="has-new-window-popup-info">Practical Guide to International Alignment of Research Data Management - Extended Version<span class="new-window-popup-info">Ouvre une nouvelle fenêtre</span></a>" (January 2021). Organised in 12 questions, it covers the six fundamental requirements for good data management and sharing in accordance with the FAIR* principles.&nbsp;</p>
      <p>The objective of this model is to make the content of the DMP both human-readable and machine-actionable, in order to provide new services or improve some existing ones.</p>
      <p>The structured template :</p>
      <ul>
        <li>facilitates <strong>automatic reuse of information</strong> (ANR projects),</li>
        <li>encourages <strong>use of identifiers</strong> (contributors, organisations, partners, etc.),</li>
        <li>proposes repositories (metadata standards, data repositories, vocabularies, etc.),</li>
        <li>identifies and lists <strong>cost types related to data management</strong>,</li>
        <li>simplifies and automates <strong>exchanges of informations</strong> with services involved in data management (e.g. data storage centre),</li>
        <li>produces a <strong>DMP format conform to</strong> <a href="https://github.com/RDA-DMP-Common/RDA-DMP-Common-Standard" target="_blank" class="has-new-window-popup-info">RDA DMP common standard<span class="new-window-popup-info">Ouvre une nouvelle fenêtre</span></a>.</li>
      </ul>
      <p>Recommendations are provided to help researchers fill this model and ensure that all relevant aspects of data management are effectively covered.</p>
      <p>* Acronym for Findable, Accessible, Interoperable, Reusable.</p>
    DESCRIPTION
  }
]
# Template creation calls defaults handler which sets is_default and
# published to false automatically, so update them after creation
templates.each { |t| Template.create!(t) if Template.find_by(title: t[:title]).nil? }

# Create 1 phase for "Science Europe modèle structuré"
phases = [
  {
    title: "PGD structuré",
    number: 1,
    modifiable: true,
    template: Template.find_by(title: "Science Europe : modèle structuré")
  },
  {
    title: "Structured DMP",
    number: 1,
    modifiable: true,
    template: Template.find_by(title: "Science Europe: structured template")
  }
]

phases.map { |p| Phase.create!(p) }

se_standard_phase_fr = Phase.find_by(
  title: "PGD structuré",
  template: Template.find_by(title: "Science Europe : modèle structuré")
)
se_standard_phase_en = Phase.find_by(
  title: "Structured DMP",
  template: Template.find_by(title: "Science Europe: structured template")
)

# Create sections for SE detailed phase
# -------------------------------------------------------
sections = [
  # Sections for Modèle structuré Science Europe Phase
  ####################################################
  ##################### FRENCH #######################
  ####################################################
  {
    title: "Description des données et collecte ou réutilisation de données existantes",
    number: 1,
    modifiable: true,
    phase: se_standard_phase_fr
  },
  {
    title: "Documentation et qualité des données",
    number: 2,
    modifiable: true,
    phase: se_standard_phase_fr
  },
  {
    title: "Exigences légales et éthiques, code de conduite",
    number: 3,
    modifiable: true,
    phase: se_standard_phase_fr
  },
  {
    title: "Traitement et analyse des données",
    number: 4,
    modifiable: true,
    phase: se_standard_phase_fr
  },
  {
    title: "Stockage et sauvegarde des données pendant le processus de recherche",
    number: 5,
    modifiable: true,
    phase: se_standard_phase_fr
  },
  {
    title: "Partage des données et conservation à long terme",
    number: 6,
    modifiable: true,
    phase: se_standard_phase_fr
  },
  ####################################################
  ##################### ENGLISH ######################
  ####################################################
  {
    title: "Data description and collection or re-use of existing data",
    number: 1,
    modifiable: true,
    phase: se_standard_phase_en
  },
  {
    title: "Documentation and data quality",
    number: 2,
    modifiable: true,
    phase: se_standard_phase_en
  },
  {
    title: "Legal and ethical requirements, codes of conduct",
    number: 3,
    modifiable: true,
    phase: se_standard_phase_en
  },
  {
    title: "Data processing and analysis",
    number: 4,
    modifiable: true,
    phase: se_standard_phase_en
  },
  {
    title: "Storage and backup during the research process",
    number: 5,
    modifiable: true,
    phase: se_standard_phase_en
  },
  {    title: "Data sharing and long-term preservation",
    number: 6,
    modifiable: true,
    phase: se_standard_phase_en
  }
]
sections.map { |s| Section.create!(s) }

structured = QuestionFormat.find_by(title: "Structured")

# Create questions for the section of SE detailed phase
# -------------------------------------------------------
questions = [
  # Questions for "Sections for Modèle structuré Science Europe" Phase,
  ####################################################
  ##################### FRENCH #######################
  ####################################################
  {
    text: "Description générale du produit de recherche",
    number: 1,
    section: Section.find_by(
      title: "Description des données et collecte ou réutilisation de données existantes",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "ResearchOutputDescriptionStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "Est-ce que des données existantes seront réutilisées ?",
    number: 2,
    section: Section.find_by(
      title: "Description des données et collecte ou réutilisation de données existantes",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataReuseStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "Comment seront produites/collectées les nouvelles données ?",
    number: 3,
    section: Section.find_by(
      title: "Description des données et collecte ou réutilisation de données existantes",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataCollectionStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Collection")]
  },
  {
    text: "Quelles métadonnées et quelle documentation (par exemple mode d'organisation des données) accompagneront les données ?" ,
    number: 1,
    section: Section.find_by(
      title: "Documentation et qualité des données",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DocumentationQualityStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Metadata & Documentation")]
  },
  {
    text: "Quelles seront les méthodes utilisées pour assurer la qualité scientifique des données ?",
    number: 2,
    section: Section.find_by(
      title: "Documentation et qualité des données",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "QualityAssuranceMethodStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Metadata & Documentation")]
  },
  {
    text: "Quelles seront les mesures appliquées pour assurer la protection des données à caractère personnel ?",
    number: 1,
    section: Section.find_by(
      title: "Exigences légales et éthiques, code de conduite",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "PersonalDataIssuesStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Ethics & Privacy")]
  },
  {
    text: "Quelles sont les contraintes juridiques (sensibilité des données autres qu'à caractère personnel, confidentialité, ...) à prendre en compte pour le partage et le stockage des données ?",
    number: 2,
    section: Section.find_by(
      title: "Exigences légales et éthiques, code de conduite",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "LegalIssuesStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Intellectual Property Rights")]
  },
  {
    text: "Quels sont les aspects éthiques à prendre en compte lors de la collecte des données ?",
    number: 3,
    section: Section.find_by(
      title: "Exigences légales et éthiques, code de conduite",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "EthicalIssuesStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "Comment et avec quels moyens seront traitées les données ?",
    number: 1,
    section: Section.find_by(
      title: "Traitement et analyse des données",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataProcessingStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "Comment les données seront-elles stockées et sauvegardées tout au long du projet ?",
    number: 1,
    section: Section.find_by(
      title: "Stockage et sauvegarde des données pendant le processus de recherche",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataStorageStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Storage & Security")]
  },
  {
    text: "Comment les données seront-elles partagées ?",
    number: 1,
    section: Section.find_by(
      title: "Partage des données et conservation à long terme",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataSharingStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Sharing"), Theme.find_by(title: "Data Repository") ]
  },
  {
    text: "Comment les données seront-elles conservées à long terme ?",
    number: 2,
    section: Section.find_by(
      title: "Partage des données et conservation à long terme",
      phase: se_standard_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataPreservationStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  ####################################################
  ##################### ENGLISH ######################
  ####################################################
  {
    text: "Research output description",
    number: 1,
    section: Section.find_by(
      title: "Data description and collection or re-use of existing data",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "ResearchOutputDescriptionStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "Will existing data be reused?",
    number: 2,
    section: Section.find_by(
      title: "Data description and collection or re-use of existing data",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataReuseStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "How new data will be collected or produced?",
    number: 3,
    section: Section.find_by(
      title: "Data description and collection or re-use of existing data",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataCollectionStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Collection")]
  },
  {
    text: "What metadata and documentation (for example way of organising data) will accompagny the data?",
    number: 1,
    section: Section.find_by(
      title: "Documentation and data quality",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DocumentationQualityStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Metadata & Documentation")]
  },
  {
    text: "What methods will be used to ensure their scientific quality?",
    number: 2,
    section: Section.find_by(
      title: "Documentation and data quality",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "QualityAssuranceMethodStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Metadata & Documentation")]
  },
  {
    text: "If personal data are processed, how will compliance with legislation on personal data and on security be ensured?",
    number: 1,
    section: Section.find_by(
      title: "Legal and ethical requirements, codes of conduct",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "PersonalDataIssuesStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Ethics & Privacy")]
  },
  {
    text: "How will other legal issues, such as intellectual property rights and ownership, be managed? What legislation is applicable?",
    number: 2,
    section: Section.find_by(
      title: "Legal and ethical requirements, codes of conduct",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "LegalIssuesStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Intellectual Property Rights")]
  },
  {
    text: "What ethical issues and codes of conduct are there, and how will they be taken into account?",
    number: 3,
    section: Section.find_by(
      title: "Legal and ethical requirements, codes of conduct",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "EthicalIssuesStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "How and with what resources will the data be processed / analyzed?",
    number: 1,
    section: Section.find_by(
      title: "Data processing and analysis",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataProcessingStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  },
  {
    text: "How will data be stored and backed up during the research?",
    number: 1,
    section: Section.find_by(
      title: "Storage and backup during the research process",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataStorageStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Storage & Security")]
  },
  {
    text: "How will data be shared?",
    number: 1,
    section: Section.find_by(
      title: "Data sharing and long-term preservation",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataSharingStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Sharing"), Theme.find_by(title: "Data Repository")]
  },
  {
    text: "How will data be long-term preserved? Which data?",
    number: 2,
    section: Section.find_by(
      title: "Data sharing and long-term preservation",
      phase: se_standard_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataPreservationStandard"),
    modifiable: true,
    themes: [Theme.find_by(title: "Data Description")]
  }
]
questions.map { |q| Question.create!(q) }
# questions.each do |q|
#   question = Question.create(q)
#   p question.errors

#   return
# end
