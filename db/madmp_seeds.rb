#!/usr/bin/env ruby
# frozen_string_literal: true
# warn_indent: true
include FactoryBot::Syntax::Methods

require "factory_bot"
require "faker"

# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

I18n.available_locales = %w[en en-GB de fr]
I18n.locale                = LocaleFormatter.new(:en, format: :i18n).to_s
# Keep this as :en. Faker doesn"t have :en-GB
Faker::Config.locale       = LocaleFormatter.new(:en, format: :i18n).to_s
FastGettext.default_locale = LocaleFormatter.new(:en, format: :fast_gettext).to_s

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
question_formats.map { |qf| create(:question_format, qf) }

# Create our generic organisation, a funder and a University
# -------------------------------------------------------
orgs = [
  {
    name: "Inist-CNRS",
    abbreviation: "INIST",
    org_type: 1, links: { "org": [] },
    language: Language.find_by(abbreviation: "fr_FR")
  }
]
orgs.map { |o| create(:org, o) }

# Create a Super Admin associated with our generic organisation,
# an Org Admin for our funder and an Org Admin and User for our University
# -------------------------------------------------------
users = [
  {
    email: "jean-dupont@example.com",
    firstname: "jean",
    surname: "Dupont",
    password: "password123",
    password_confirmation: "password123",
    org: Org.find_by(abbreviation: "INIST"),
    language: Language.find_by(abbreviation: FastGettext.locale),
    accept_terms: true,
    confirmed_at: Time.zone.now
  }
]
users.map { |u| create(:user, u) }

# Create a default template for the curation centre and one for the example funder
# -------------------------------------------------------
templates = [
  {
    title: "Science Europe modèle structuré",
    description: "Modèle basé sur Science Europe, s'appuyant sur les schémas de base",
    published: true,
    org: Org.find_by(abbreviation: "INIST"),
    locale: "fr_FR",
    is_default: true,
    version: 0,
    visibility: Template.visibilities[:organisationally_visible],
    links: { "funder": [], "sample_plan": [] }
  }
]
# Template creation calls defaults handler which sets is_default and
# published to false automatically, so update them after creation
templates.each { |atts| create(:template, atts) }

# Create 1 phase for "Science Europe modèle structuré"
phases = [
  {
    title: "DMP détaillé",
    number: 1,
    modifiable: true,
    template: Template.find_by(title: "Science Europe modèle structuré")
  }
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
  {
    title: "Traitement et analyse des données",
    number: 4,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  {
    title: "Stockage et sauvegarde des données pendant le processus de recherche",
    number: 5,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  {
    title: "Partage et conservation des données",
    number: 6,
    modifiable: false,
    phase: se_detailed_phase_1
  },
  {
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
  {
    text: "Description générale du produit de recherche",
    number: 1,
    section: Section.find_by(title: "Description des données et collecte des données et/ou réutilisation de données existantes"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "research_output_description"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data Description")]
  },

  {
    text: "Est-ce que des données existantes seront réutilisées",
    number: 2,
    section: Section.find_by(title: "Description des données et collecte des données et/ou réutilisation de données existantes"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_reuse"),
    modifiable: false
  },

  {
    text: "Comment seront produites/collectées les nouvelles données",
    number: 3,
    section: Section.find_by(title: "Description des données et collecte des données et/ou réutilisation de données existantes"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_collection"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data Collection")]
  },

  {
    text: "Comment seront organisées et documentées les données? Quelles seront les méthodes utilisées pour assurer leur qualité scientifique",
    number: 1,
    section: Section.find_by(title: "Documentation et métadonnées"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "documentation_quality"),
    modifiable: false,
    themes: [Theme.find_by(title: "Metadata & Documentation")]
  },

  {
    text: "Quelles seront les mesures appliquées pour assurer la protection des données personnelles ?",
    number: 1,
    section: Section.find_by(title: "Exigences légales et éthiques, code de conduite"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "personal_data_issues"),
    modifiable: false,
    themes: [Theme.find_by(title: "Ethics & Privacy")]
  },

  {
    text: "Quelles sont les contraintes juridiques (sensibilité des données autres qu'à caractère personnel, confidentialité, ...) à prendre en compte pour le partage et le stockage des données ?",
    number: 2,
    section: Section.find_by(title: "Exigences légales et éthiques, code de conduite"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "legal_issues"),
    modifiable: false,
    themes: [Theme.find_by(title: "Intellectual Property Right")]
  },

  {
    text: "Quels sont les aspects éthiques à prendre en compte lors de la collecte des données ?",
    number: 3,
    section: Section.find_by(title: "Exigences légales et éthiques, code de conduite"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "ethical_issues"),
    modifiable: false
  },

  {
    text: "Comment et avec quels moyens seront traitées les données ?",
    number: 1,
    section: Section.find_by(title: "Traitement et analyse des données"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_processing"),
    modifiable: false
  },

  {
    text: "Comment les données seront-elles stockées et sauvegardées tout au long du projet ?",
    number: 1,
    section: Section.find_by(title: "Stockage et sauvegarde des données pendant le processus de recherche"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_storage"),
    modifiable: false,
    themes: [Theme.find_by(title: "Storage & Security")]
  },

  {
    text: "Comment les données seront-elles partagées ?",
    number: 1,
    section: Section.find_by(title: "Partage et conservation des données"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_sharing"),
    modifiable: false,
    themes: [Theme.find_by(title: "Data Sharing"), Theme.find_by(title: "Data Repository") ]
  },

  {
    text: "Comment les données seront-elles conservées à long terme ?",
    number: 2,
    section: Section.find_by(title: "Partage et conservation des données"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "data_preservation"),
    modifiable: false
  },

  {
    text: "Décrire la répartition des rôles et reponsabilités parmi les contributeurs ainsi que les côuts induits pour la gestion des données ?",
    number: 1,
    section: Section.find_by(title: "Ressources allouées pour la gestion"),
    question_format: structured,
    madmp_schema: MadmpSchema.find_by(classname: "budget"),
    modifiable: false
  }
]
questions.map { |q| create(:question, q) }

# Create suggested answers for a few questions
# -------------------------------------------------------
annotations = [
  {
    text: "Les données seront partagées dans un entrepôt ouvert tel que Zenodo s'il n'existe pas d'entrepôt thématique adéquat.",
    type: Annotation.types[:example_answer],
    org: Org.find_by(abbreviation: "INIST"),
    question: Question.find_by(text: "Comment les données seront-elles partagées ?")
  },
  {
    text: "Aucunes données existantes (au sein du laboratoire ou accessibles via) ne peuvent être réutilisées dans cette étude. ",
    type: Annotation.types[:example_answer],
    org: Org.find_by(abbreviation: "INIST"),
    question: Question.find_by(text: "Est-ce que des données existantes seront réutilisées")
  }
]
annotations.map { |s| Annotation.create!(s) if Annotation.find_by(text: s[:text]).nil? }

# Create registries
# -------------------------------------------------------

registries = [
  {
    name: "Role",
    description: "Role of a contributor",
    uri: nil,
    version: 1
  },
  {
    name: "Cost type",
    description: "Cost type",
    uri: nil,
    version: 1
  },
  {
    name: "Currency",
    description: "Currency",
    uri: nil,
    version: 1
  },
  {
    name: "Data Nature",
    description: "Data Nature",
    uri: nil,
    version: 1
  },
  {
    name: "Resource Identifier",
    description: "Resource Identifier",
    uri: nil,
    version: 1
  },
  {
    name: "Data Access",
    description: "Data Access",
    uri: nil,
    version: 1
  },
  {
    name: "File format",
    description: "File format",
    uri: nil,
    version: 1
  },
  {
    name: "Agent ID",
    description: "User, Org or Funder Identifier",
    uri: nil,
    version: 1
  },
  {
    name: "Language Code",
    description: "Language Code",
    uri: nil,
    version: 1
  },
  {
    name: "Research Output Type",
    description: "Research Output Type",
    uri: nil,
    version: 1
  },
  {
    name: "Yes No Unknown",
    description: "Yes No Unknown",
    uri: nil,
    version: 1
  },
  {
    name: "Country code",
    description: "Country code",
    uri: nil,
    version: 1
  },
  {
    name: "Certification",
    description: "Certification",
    uri: nil,
    version: 1
  },
  {
    name: "Storage Type",
    description: "Storage Type",
    uri: nil,
    version: 1
  }
]

registries.map { |r| Registry.create!(r) if Registry.find_by(name: r[:name]).nil? }

# Create registry values
# -------------------------------------------------------
registry_values = [
  # Role registry
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Role"),
    value: {
      "value": {
        "en_GB": "Data producer",
        "fr_FR": "Producteur de données"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Role"),
    value: {
      "value": {
        "en_GB": "Data manager",
        "fr_FR": "Gestionnaire de données"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Role"),
    value: {
      "value": "Data steward"
    }
  },
  {
    registry: Registry.find_by(name: "Role"),
    value: {
      "value": {
        "en_GB": "Legal Expert",
        "fr_FR": "Expert juridique"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Role"),
    value: {
      "value": {
        "en_GB": "Data Protection Officer",
        "fr_FR": "Responsable de la protection des données"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Role"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Cost type registry
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Cost type"),
    value: {
      "value": {
        "en_GB": "Human resource",
        "fr_FR": "Ressources humaines"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Cost type"),
    value: {
      "value": {
        "en_GB": "Training",
        "fr_FR": "Formation"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Cost type"),
    value: {
      "value": {
        "en_GB": "Software",
        "fr_FR": "Logiciel"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Cost type"),
    value: {
      "value": {
        "en_GB": "Hardware",
        "fr_FR": "Matériel informatique"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Cost type"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Currency
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Currency"),
    value: {
      "value": "EUR"
    }
  },
  {
    registry: Registry.find_by(name: "Currency"),
    value: {
      "value": "GBP"
    }
  },
  {
    registry: Registry.find_by(name: "Currency"),
    value: {
      "value": "USD"
    }
  },
  # Data Nature
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Data Nature"),
    value: {
      "value": "Observation"
    }
  },
  {
    registry: Registry.find_by(name: "Data Nature"),
    value: {
      "value": {
        "en_GB": "Experimental Data",
        "fr_FR": "Données expérimentales"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Data Nature"),
    value: {
      "value": "Simulation"
    }
  },
  {
    registry: Registry.find_by(name: "Data Nature"),
    value: {
      "value": {
        "en_GB": "Model",
        "fr_FR": "Modèle"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Data Nature"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # File format
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "File format"),
    value: {
      "value": "text/csv"
    }
  },
  {
    registry: Registry.find_by(name: "File format"),
    value: {
      "value": "text/markdown"
    }
  },
  {
    registry: Registry.find_by(name: "File format"),
    value: {
      "value": "video/JPEG"
    }
  },
  {
    registry: Registry.find_by(name: "File format"),
    value: {
      "value": "application/json"
    }
  },
  {
    registry: Registry.find_by(name: "File format"),
    value: {
      "value": "..."
    }
  },
  # Resource Identifier
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Resource Identifier"),
    value: {
      "value": "DOI"
    }
  },
  {
    registry: Registry.find_by(name: "Resource Identifier"),
    value: {
      "value": "ARK"
    }
  },
  {
    registry: Registry.find_by(name: "Resource Identifier"),
    value: {
      "value": "HANDLE"
    }
  },
  {
    registry: Registry.find_by(name: "Resource Identifier"),
    value: {
      "value": "IGSN"
    }
  },
  {
    registry: Registry.find_by(name: "Resource Identifier"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Agent ID
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Agent ID"),
    value: {
      "value": "ORCID"
    }
  },
  {
    registry: Registry.find_by(name: "Agent ID"),
    value: {
      "value": "ROR ID"
    }
  },
  {
    registry: Registry.find_by(name: "Agent ID"),
    value: {
      "value": "FundRef"
    }
  },
  {
    registry: Registry.find_by(name: "Agent ID"),
    value: {
      "value": "ISSNI"
    }
  },
  {
    registry: Registry.find_by(name: "Agent ID"),
    value: {
      "value": "IdRef"
    }
  },
  {
    registry: Registry.find_by(name: "Agent ID"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Research Output Type
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": {
        "en_GB": "Dataset",
        "fr_FR": "Jeu de données"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": {
        "en_GB": "Software",
        "fr_FR": "Logiciel"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": {
        "en_GB": "Model",
        "fr_FR": "Modèle"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": {
        "en_GB": "Physical object",
        "fr_FR": "Objet physique"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": {
        "en_GB": "Protocol",
        "fr_FR": "Protocole"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": "Workflow"
    }
  },
  {
    registry: Registry.find_by(name: "Research Output Type"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Yes No Unknown
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Yes No Unknown"),
    value: {
      "value": {
        "en_GB": "Yes",
        "fr_FR": "Oui"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Yes No Unknown"),
    value: {
      "value": {
        "en_GB": "No",
        "fr_FR": "Non"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Yes No Unknown"),
    value: {
      "value": {
        "en_GB": "Unknown",
        "fr_FR": "Ne sais pas"
      }
    }
  },
  # Country code
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Country code"),
    value: {
      "value": "FR"
    }
  },
  {
    registry: Registry.find_by(name: "Country code"),
    value: {
      "value": "GB"
    }
  },
  {
    registry: Registry.find_by(name: "Country code"),
    value: {
      "value": "US"
    }
  },
  {
    registry: Registry.find_by(name: "Country code"),
    value: {
      "value": "DE"
    }
  },
  # Certification
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Certification"),
    value: {
      "value": "CoreTrustSeal"
    }
  },
  {
    registry: Registry.find_by(name: "Certification"),
    value: {
      "value": "WDS"
    }
  },
  {
    registry: Registry.find_by(name: "Certification"),
    value: {
      "value": "DSA"
    }
  },
  {
    registry: Registry.find_by(name: "Certification"),
    value: {
      "value": "ISO-9001"
    }
  },
  {
    registry: Registry.find_by(name: "Certification"),
    value: {
      "value": "ISO-27000"
    }
  },
  {
    registry: Registry.find_by(name: "Yes No Unknown"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Storage Type
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": {
        "en_GB": "Hard disk drive",
        "fr_FR": "Disque dur"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": {
        "en_GB": "Solid state drive",
        "fr_FR": "Disque SSD"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": {
        "en_GB": "USB key",
        "fr_FR": "Clé USB"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": {
        "en_GB": "NAS server",
        "fr_FR": "Serveur NAS"
      }
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": "Cloud"
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": "CD"
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": "DVD"
    }
  },
  {
    registry: Registry.find_by(name: "Storage Type"),
    value: {
      "value": {
        "en_GB": "Other",
        "fr_FR": "Autre"
      }
    }
  },
  # Language Code
  # -------------------------------------------------------
  {
    registry: Registry.find_by(name: "Language Code"),
    value: {
      "label": {
        "en_GB": "French",
        "fr_FR": "Français"
      },
      "code": "fra"
    }
  },
  {
    registry: Registry.find_by(name: "Language Code"),
    value: {
      "label": {
        "en_GB": "English",
        "fr_FR": "Anglais"
      },
      "code": "eng"
    }
  }
]

registry_values.map { |r| RegistryValue.create!(r) }
