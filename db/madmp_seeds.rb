#!/usr/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true
# warn_indent: true

# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

require 'factory_bot'
require 'faker'

include FactoryBot::Syntax::Methods

I18n.available_locales = ['en', 'en-GB', 'de', 'fr']
I18n.locale                = LocaleFormatter.new(:en, format: :i18n).to_s
# Keep this as :en. Faker doesn't have :en-GB
Faker::Config.locale       = LocaleFormatter.new(:en, format: :i18n).to_s
FastGettext.default_locale = LocaleFormatter.new(:en, format: :fast_gettext).to_s


require 'factory_bot'
include FactoryBot::Syntax::Methods



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
question_formats.map{ |qf| create(:question_format, qf) }





# Create our generic organisation, a funder and a University
# -------------------------------------------------------
orgs = [
  {name: 'Inist-CNRS',
    abbreviation: 'INIST',
    org_type: 1, links: {" org":[]},
    language: Language.find_by(abbreviation: 'fr_FR')}
]
orgs.map{ |o| create(:org, o) }

# Create a Super Admin associated with our generic organisation,
# an Org Admin for our funder and an Org Admin and User for our University
# -------------------------------------------------------
users = [
   {email: "jean-dupont@example.com",
    firstname: "jean",
    surname: "Dupont",
    password: "password123",
    password_confirmation: "password123",
    org: Org.find_by(abbreviation: 'INIST'),
    language: Language.find_by(abbreviation: FastGettext.locale),
    accept_terms: true,
    confirmed_at: Time.zone.now}
]
users.map{ |u| create(:user, u) }


# Create a default template for the curation centre and one for the example funder
# -------------------------------------------------------
templates = [
  {title: "Science Europe modèle structuré",
    description:"Modèle basé sur Science Europe, s'appuyant sur les schémas de base"
    published: true,
    org: Org.find_by(abbreviation: 'INIST'),
    locale:"fr_FR",
    is_default: true,
    version: 0,
    visibility: Template.visibilities[:organisationally_visible],
    links: {"funder":[],"sample_plan":[]}}
]
# Template creation calls defaults handler which sets is_default and
# published to false automatically, so update them after creation
templates.each { |atts| create(:template, atts) }

#Create 1 phase for "Science Europe modèle structuré"
phases = [

   {title: "DMP détaillé",
    number: 1,
    modifiable: true,
    template: Template.find_by(title: "Science Europe modèle structuré")},
]
phases.map{ |p| create(:phase, p) }


se_detailed_phase_1 = Phase.find_by(title: "DMP détaillé")

# Create sections for SE detailed phase
# -------------------------------------------------------
sections = [
  
  # Sections for Modèle structuré Science Europe Phase
  {
    title: "Description des données et collecte des données et/ou réutilisation de données existantes",
    number: 1,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  {
    title: "Documentation et métadonnées",
    number: 2,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  {
    title: "Exigences légales et éthiques, code de conduite",
    number: 3,
    modifiable: false,
    phase: se_detailed_phase_1
  },
    title: "Traitement et analyse des données",
    number: 4,
    modifiable: false,
    phase: se_detailed_phase_1
  },
    title: "Stockage et sauvegarde des données pendant le processus de recherche",
    number: 5,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  title: "Partage et conservation des données",
    number: 6,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  title: "Ressources allouées pour la gestion",
    number: 7,
    modifiable: false,
    phase: se_detailed_phase_1
  }
]
sections.map{ |s| create(:section, s) }


structured = QuestionFormat.find_by(title: "Structured")

# Create questions for the section of SE detailed phase
# -------------------------------------------------------
questions = [
  
   # Questions for "Sections for Modèle structuré Science Europe" Phase,
   {text: "Description générale du produit de recherche",
    number: 1,
    section: Section.find_by(title: "Description des données et collecte des données et/ou réutilisation de données existantes"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "research_output_description")
    modifiable: false,
    themes: [Theme.find_by(title: "Data Description")]},

    {text: "Est-ce que des données existantes seront réutilisées",
    number: 2,
    section: Section.find_by(title: "Description des données et collecte des données et/ou réutilisation de données existantes"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_reuse")
    modifiable: false},
    
    {text: "Comment seront produites/collectées les nouvelles données",
    number: 3,
    section: Section.find_by(title: "Description des données et collecte des données et/ou réutilisation de données existantes"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_collection")
    modifiable: false,
    themes: [Theme.find_by(title: "Data Collection")]},

    {text: "Comment seront organisées et documentées les données? Quelles seront les méthodes utilisées pour assurer leur qualité scientifique",
    number: 1,
    section: Section.find_by(title: "Documentation et métadonnées"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "documentation_quality")
    modifiable: false,
    themes: [Theme.find_by(title: "Metadata & Documentation")]},

    {text: "Quelles seront les mesures appliquées pour assurer la protection des données personnelles ?",
    number: 1,
    section: Section.find_by(title: "Exigences légales et éthiques, code de conduite"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "personal_data_issues")
    modifiable: false,
    themes: [Theme.find_by(title: "Ethics & Privacy")]},

    {text: "Quelles sont les contraintes juridiques (sensibilité des données autres qu'à caractère personnel, confidentialité, ...) à prendre en compte pour le partage et le stockage des données ?",
    number: 2,
    section: Section.find_by(title: "Exigences légales et éthiques, code de conduite"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "legal_issues")
    modifiable: false,
    themes: [Theme.find_by(title: "Intellectual Property Right")]},

    {text: "Quels sont les aspects éthiques à prendre en compte lors de la collecte des données ?",
    number: 3,
    section: Section.find_by(title: "Exigences légales et éthiques, code de conduite"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "ethical_issues")
    modifiable: false},

    {text: "Comment et avec quels moyens seront traitées les données ?",
    number: 1,
    section: Section.find_by(title: "Traitement et analyse des données"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_processing")
    modifiable: false},

    {text: "Comment les données seront-elles stockées et sauvegardées tout au long du projet ?",
    number: 1,
    section: Section.find_by(title: "Stockage et sauvegarde des données pendant le processus de recherche"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_storage")
    modifiable: false,
    themes: [Theme.find_by(title: "Storage & Security")]},

    {text: "Comment les données seront-elles partagées ?",
    number: 1,
    section: Section.find_by(title: "Partage et conservation des données"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_sharing")
    modifiable: false,
    themes: [Theme.find_by(title: "Data Sharing"), Theme.find_by(title: "Data Repository") ]},

    {text: "Comment les données seront-elles conservées à long terme ?",
    number: 2,
    section: Section.find_by(title: "Partage et conservation des données"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_preservation")
    modifiable: false},

    {text: "Décrire la répartition des rôles et reponsabilités parmi les contributeurs ainsi que les côuts induits pour la gestion des données ?",
    number: 1,
    section: Section.find_by(title: "Ressources allouées pour la gestion"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "budget")
    modifiable: false}
]
questions.map{ |q| create(:question, q) }


# Create suggested answers for a few questions
# -------------------------------------------------------
annotations = [
  {text: "Les données seront partagées dans un entrepôt ouvert tel que Zenodo s'il n'existe pas d'entrepôt thématique adéquat.",
   type: Annotation.types[:example_answer],
   org: Org.find_by(abbreviation: 'INIST'),
   question: Question.find_by(text: "Comment les données seront-elles partagées ?")},
  {text: "Aucunes données existantes (au sein du laboratoire ou accessibles via) ne peuvent être réutilisées dans cette étude. ",
   type: Annotation.types[:example_answer],
   org: Org.find_by(abbreviation: 'INIST'),
   question: Question.find_by(text: "Est-ce que des données existantes seront réutilisées")}
]
annotations.map{ |s| Annotation.create!(s) if Annotation.find_by(text: s[:text]).nil? }

