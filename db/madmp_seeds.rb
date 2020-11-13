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
    language: Language.find_by(abbreviation: "fr_FR")
  }
]

orgs.each { |o| Org.create!(o) if Org.find_by(name: o[:name]).nil? }

# Create a default template for the curation centre and one for the example funder
# -------------------------------------------------------
templates = [
  {
    title: "Science Europe modèle structuré",
    description: "Modèle basé sur Science Europe, s'appuyant sur les schémas de base",
    published: true,
    org: Org.find_by(abbreviation: "Science Europe"),
    locale: "fr_FR",
    is_default: true,
    version: 0,
    visibility: Template.visibilities[:organisationally_visible],
    links: { "funder": [], "sample_plan": [] }
  },
  {
    title: "Science Europe structured template",
    description: "Science Europe structured template",
    published: true,
    org: Org.find_by(abbreviation: "Science Europe"),
    locale: "en_GB",
    is_default: true,
    version: 0,
    visibility: Template.visibilities[:organisationally_visible],
    links: { "funder": [], "sample_plan": [] }
  }
]
# Template creation calls defaults handler which sets is_default and
# published to false automatically, so update them after creation
templates.each { |t| Template.create!(t) if Template.find_by(title: t[:title]).nil? }

# Create 1 phase for "Science Europe modèle structuré"
phases = [
  {
    title: "DMP détaillé",
    number: 1,
    modifiable: true,
    template: Template.find_by(title: "Science Europe modèle structuré")
  },
  {
    title: "Detailed DMP",
    number: 1,
    modifiable: true,
    template: Template.find_by(title: "Science Europe structured template")
  }
]

phases.map { |p| Phase.create!(p) }

se_detailed_phase_fr = Phase.find_by(
  title: "DMP détaillé",
  template: Template.find_by(title: "Science Europe modèle structuré")
)
se_detailed_phase_en = Phase.find_by(
  title: "Detailed DMP",
  template: Template.find_by(title: "Science Europe structured template")
)

# Create sections for SE detailed phase
# -------------------------------------------------------
sections = [
  # Sections for Modèle structuré Science Europe Phase
  ####################################################
  ##################### FRENCH #######################
  ####################################################
  {
    title: "Description des données et collecte des données et/ou réutilisation de données existantes",
    number: 1,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  {
    title: "Documentation et métadonnées",
    number: 2,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  {
    title: "Exigences légales et éthiques, code de conduite",
    number: 3,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  {
    title: "Traitement et analyse des données",
    number: 4,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  {
    title: "Stockage et sauvegarde des données pendant le processus de recherche",
    number: 5,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  {
    title: "Partage et conservation des données",
    number: 6,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  {
    title: "Ressources allouées pour la gestion",
    number: 7,
    modifiable: false,
    phase: se_detailed_phase_fr
  },
  ####################################################
  ##################### ENGLISH ######################
  ####################################################
  {
    title: "Data description and collection or re-use of existing data",
    number: 1,
    modifiable: false,
    phase: se_detailed_phase_en
  },
  {
    title: "Documentation and metadata",
    number: 2,
    modifiable: false,
    phase: se_detailed_phase_en
  },
  {
    title: "Legal and ethical requirements, codes of conduct",
    number: 3,
    modifiable: false,
    phase: se_detailed_phase_en
  },
  {
    title: "Data processing and analysis",
    number: 4,
    modifiable: false,
    phase: se_detailed_phase_en
  },
  {
    title: "Storage and backup during the research process",
    number: 5,
    modifiable: false,
    phase: se_detailed_phase_en
  },
  {
    title: "Data sharing and long-term preservation",
    number: 6,
    modifiable: false,
    phase: se_detailed_phase_en
  },
  {
    title: "Resources for data management",
    number: 7,
    modifiable: false,
    phase: se_detailed_phase_en
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
      title: "Description des données et collecte des données et/ou réutilisation de données existantes",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "ResearchOutputDescriptionStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data description")]
  },
  {
    text: "Est-ce que des données existantes seront réutilisées",
    number: 2,
    section: Section.find_by(
      title: "Description des données et collecte des données et/ou réutilisation de données existantes",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataReuseStandard"),
    modifiable: false
  },
  {
    text: "Comment seront produites/collectées les nouvelles données",
    number: 3,
    section: Section.find_by(
      title: "Description des données et collecte des données et/ou réutilisation de données existantes",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataCollectionStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data collection")]
  },
  {
    text: "Comment seront organisées et documentées les données? Quelles seront les méthodes utilisées pour assurer leur qualité scientifique",
    number: 1,
    section: Section.find_by(
      title: "Documentation et métadonnées",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DocumentationQualityStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Metadata & documentation")]
  },
  {
    text: "Quelles seront les mesures appliquées pour assurer la protection des données personnelles ?",
    number: 1,
    section: Section.find_by(
      title: "Exigences légales et éthiques, code de conduite",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "PersonalDataIssuesStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Ethics & privacy")]
  },
  {
    text: "Quelles sont les contraintes juridiques (sensibilité des données autres qu'à caractère personnel, confidentialité, ...) à prendre en compte pour le partage et le stockage des données ?",
    number: 2,
    section: Section.find_by(
      title: "Exigences légales et éthiques, code de conduite",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "LegalIssuesStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Intellectual Property Rights")]
  },
  {
    text: "Quels sont les aspects éthiques à prendre en compte lors de la collecte des données ?",
    number: 3,
    section: Section.find_by(
      title: "Exigences légales et éthiques, code de conduite",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "EthicalIssuesStandard"),
    modifiable: false
  },
  {
    text: "Comment et avec quels moyens seront traitées les données ?",
    number: 1,
    section: Section.find_by(
      title: "Traitement et analyse des données",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataProcessingStandard"),
    modifiable: false
  },
  {
    text: "Comment les données seront-elles stockées et sauvegardées tout au long du projet ?",
    number: 1,
    section: Section.find_by(
      title: "Stockage et sauvegarde des données pendant le processus de recherche",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataStorageStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Storage & security")]
  },
  {
    text: "Comment les données seront-elles partagées ?",
    number: 1,
    section: Section.find_by(
      title: "Partage et conservation des données",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataSharingStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data sharing"), Theme.find_by(title: "Data repository") ]
  },
  {
    text: "Comment les données seront-elles conservées à long terme ?",
    number: 2,
    section: Section.find_by(
      title: "Partage et conservation des données",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataPreservationStandard"),
    modifiable: false
  },
  {
    text: "Décrire la répartition des rôles et reponsabilités parmi les contributeurs ainsi que les côuts induits pour la gestion des données ?",
    number: 1,
    section: Section.find_by(
      title: "Ressources allouées pour la gestion",
      phase: se_detailed_phase_fr
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "BudgetStandard"),
    modifiable: false
  },
  ####################################################
  ##################### ENGLISH ######################
  ####################################################
  {
    text: "Research output description",
    number: 1,
    section: Section.find_by(
      title: "Data description and collection or re-use of existing data",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "ResearchOutputDescriptionStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data description")]
  },
  {
    text: "Will existing data be reused?",
    number: 2,
    section: Section.find_by(
      title: "Data description and collection or re-use of existing data",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataReuseStandard"),
    modifiable: false
  },
  {
    text: "How will new data be collected or produced?",
    number: 3,
    section: Section.find_by(
      title: "Data description and collection or re-use of existing data",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataCollectionStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data collection")]
  },
  {
    text: "How will data be organised and documented? What methods will be used to ensure their scientific quality?",
    number: 1,
    section: Section.find_by(
      title: "Documentation and metadata",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DocumentationQualityStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Metadata & documentation")]
  },
  {
    text: "If personal data are processed, how will compliance with legislation on personal data and on security be ensured?",
    number: 1,
    section: Section.find_by(
      title: "Legal and ethical requirements, codes of conduct",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "PersonalDataIssuesStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Ethics & privacy")]
  },
  {
    text: "How will other legal issues, such as intellectual property rights and ownership, be managed? What legislation is applicable?",
    number: 2,
    section: Section.find_by(
      title: "Legal and ethical requirements, codes of conduct",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "LegalIssuesStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Intellectual Property Rights")]
  },
  {
    text: "What ethical issues and codes of conduct are there, and how will they be taken into account?",
    number: 3,
    section: Section.find_by(
      title: "Legal and ethical requirements, codes of conduct",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "EthicalIssuesStandard"),
    modifiable: false
  },
  {
    text: "How and with what resources will the data be processed / analyzed?",
    number: 1,
    section: Section.find_by(
      title: "Data processing and analysis",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataProcessingStandard"),
    modifiable: false
  },
  {
    text: "How will data be stored and backed up during the research?",
    number: 1,
    section: Section.find_by(
      title: "Storage and backup during the research process",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataStorageStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Storage & security")]
  },
  {
    text: "How will data ba shared?",
    number: 1,
    section: Section.find_by(
      title: "Data sharing and long-term preservation",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataSharingStandard"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data sharing"), Theme.find_by(title: "Data repository")]
  },
  {
    text: "How will data be log-term preservation? Which data?",
    number: 2,
    section: Section.find_by(
      title: "Data sharing and long-term preservation",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "DataPreservationStandard"),
    modifiable: false
  },
  {
    text: "Outline the roles and responsibilities for data management/stewardship activities and the dedicated costs",
    number: 1,
    section: Section.find_by(
      title: "Resources for data management",
      phase: se_detailed_phase_en
    ),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(name: "BudgetStandard"),
    modifiable: false
  }
]
questions.map { |q| Question.create!(q) }
# questions.each do |q|
#   question = Question.create(q)
#   p question.errors

#   return
# end

# Create suggested answers for a few questions
# -------------------------------------------------------
annotations = [
  {
    text: "Les données seront partagées dans un entrepôt ouvert tel que Zenodo s'il n'existe pas d'entrepôt thématique adéquat.",
    type: Annotation.types[:example_answer],
    org: Org.find_by(abbreviation: "Science Europe"),
    question: Question.find_by(text: "Comment les données seront-elles partagées ?")
  },
  {
    text: "Aucunes données existantes (au sein du laboratoire ou accessibles via) ne peuvent être réutilisées dans cette étude. ",
    type: Annotation.types[:example_answer],
    org: Org.find_by(abbreviation: "Science Europe"),
    question: Question.find_by(text: "Est-ce que des données existantes seront réutilisées")
  }
]
annotations.map { |s| Annotation.create!(s) if Annotation.find_by(text: s[:text]).nil? }
