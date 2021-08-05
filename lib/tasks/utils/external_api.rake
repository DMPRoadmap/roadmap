# frozen_string_literal: true

<<<<<<< HEAD
namespace :external_api do

  desc "Seed the Field of Science (fos) table"
  task load_field_of_science: :environment do
=======
# rubocop:disable Metrics/BlockLength, Layout/LineLength
namespace :external_api do
  desc "Fetch the latest RDA Metadata Standards"
  task load_rdamsc_standards: :environment do
    p "Fetching the latest RDAMSC metadata standards and updating the metadata_standards table"
    ExternalApis::RdamscService.fetch_metadata_standards
  end

  desc "Load Repositories from re3data"
  task load_re3data_repos: :environment do
    p "Fetching the latest re3data repository metadata and updating the repositories table"
    p "This can take in excess of 10 minutes to complete ..."
    ExternalApis::Re3dataService.fetch
  end

  desc "Load Licenses from SPDX"
  task load_spdx_licenses: :environment do
    p "Fetching the latest SPDX license metadata and updating the licenses table"
    ExternalApis::SpdxService.fetch
  end

  desc "Seed the Research Domain table with Field of Science categories"
  task add_field_of_science_to_research_domains: :environment do
>>>>>>> roadmap-development
    # TODO: If we can identify an external API authority for this information we should switch
    #       to fetch the list from there instead of the hard-coded list below which was derived from:
    #       https://www.oecd.org/science/inno/38235147.pdf
    [
      {
        identifier: "1",
        label: "Natural sciences",
<<<<<<< HEAD
        keywords: "",
        children: [
          { identifier: "1.1", label: "Mathematics", keywords: "astronomy algebra calcul geometr logic mathematic physics probability statistic topology" },
          { identifier: "1.2", label: "Computer and information sciences", keywords: "artificial computation computer" },
          { identifier: "1.3", label: "Physical sciences", keywords: "astronomy atmospher chemistry crystallography earth electronics materials meteorology ocean physics space thermodynamic" },
          { identifier: "1.4", label: "Chemical sciences", keywords: "chemical chemistry" },
          { identifier: "1.5", label: "Earth and related environmental sciences", keywords: "atmospher biology climate earth ecology environmental meteorology ocean seism" },
          { identifier: "1.6", label: "Biological sciences", keywords: "anatomy biochemistry biodiversity biology botany ecology genetics morphology mycology zoology" },
          { identifier: "1.7", label: "Other natural sciences", keywords: "" }
=======
        children: [
          { identifier: "1.1", label: "Mathematics" },
          { identifier: "1.2", label: "Computer and information sciences" },
          { identifier: "1.3", label: "Physical sciences" },
          { identifier: "1.4", label: "Chemical sciences" },
          { identifier: "1.5", label: "Earth and related environmental sciences" },
          { identifier: "1.6", label: "Biological sciences" },
          { identifier: "1.7", label: "Other natural sciences" }
>>>>>>> roadmap-development
        ]
      },
      {
        identifier: "2",
        label: "Engineering and Technology",
<<<<<<< HEAD
        keywords: "engineering technol",
        children: [
          { identifier: "2.1", label: "Civil engineering", keywords: "coastal construction earthquake environmental geotechnical material municipal structural surveying transportation" },
          { identifier: "2.2", label: "Electrical engineering, electronic engineering,  information engineering", keywords: "electrical electronic information semiconductor" },
          { identifier: "2.3", label: "Mechanical engineering", keywords: "drafting mechanic mechatronic structural thermodynamic" },
          { identifier: "2.4", label: "Chemical engineering", keywords: "" },
          { identifier: "2.5", label: "Materials engineering", keywords: "alloy ceramics composites electronic glasses magnetic materials monomer optical polymer semiconductor" },
          { identifier: "2.6", label: "Medical engineering", keywords: "biomedical bionics genetic implants medical neural pharmaceutical tissue" },
          { identifier: "2.7", label: "Environmental engineering", keywords: "environ pollution waste" },
          { identifier: "2.8", label: "Environmental biotechnology", keywords: "" },
          { identifier: "2.9", label: "Industrial Biotechnology", keywords: "" },
          { identifier: "2.10", label: "Nano-technology", keywords: "biomimetic nanoelectron nanomaterial nanotech" },
          { identifier: "2.11", label: "Other engineering and technologies", keywords: "" }
=======
        children: [
          { identifier: "2.1", label: "Civil engineering" },
          { identifier: "2.2", label: "Electrical engineering, electronic engineering,  information engineering" },
          { identifier: "2.3", label: "Mechanical engineering" },
          { identifier: "2.4", label: "Chemical engineering" },
          { identifier: "2.5", label: "Materials engineering" },
          { identifier: "2.6", label: "Medical engineering" },
          { identifier: "2.7", label: "Environmental engineering" },
          { identifier: "2.8", label: "Environmental biotechnology" },
          { identifier: "2.9", label: "Industrial Biotechnology" },
          { identifier: "2.10", label: "Nano-technology" },
          { identifier: "2.11", label: "Other engineering and technologies" }
>>>>>>> roadmap-development
        ]
      },
      {
        identifier: "3",
        label: "Medical and Health Sciences",
<<<<<<< HEAD
        keywords: "anesthes angiology audiology bariatric cardio dental dentist dermatol disease endocrin gastroent geriatric gynecol health hematol hepatol infectious kinesiol laboratory medical medicine neurol nephrol oncolo ophthalm orthop otolaryn patholo pediatric pharmacol pulmonol psychiatr radiolo rheumatol splanchn surgery surgical urolo veterinar",
        children: [
          { identifier: "3.1", label: "Basic medicine", keywords: "" },
          { identifier: "3.2", label: "Clinical medicine", keywords: "" },
          { identifier: "3.3", label: "Health sciences", keywords: "" },
          { identifier: "3.4", label: "Health biotechnology", keywords: "" },
          { identifier: "3.5", label: "Other medical sciences", keywords: "" }
=======
        children: [
          { identifier: "3.1", label: "Basic medicine" },
          { identifier: "3.2", label: "Clinical medicine" },
          { identifier: "3.3", label: "Health sciences" },
          { identifier: "3.4", label: "Health biotechnology" },
          { identifier: "3.5", label: "Other medical sciences" }
>>>>>>> roadmap-development
        ]
      },
      {
        identifier: "4",
        label: "Agricultural Sciences",
<<<<<<< HEAD
        keywords: "agricultur biodiversity ecology habitat veterinar",
        children: [
          { identifier: "4.1", label: "Agriculture, forestry, and fisheries", keywords: "aquaculture fisheries fishery forest timber" },
          { identifier: "4.2", label: "Animal and dairy science", keywords: "" },
          { identifier: "4.3", label: "Veterinary science", keywords: "animal veterinar" },
          { identifier: "4.4", label: "Agricultural biotechnology", keywords: "" },
          { identifier: "4.5", label: "Other agricultural sciences", keywords: "" }
=======
        children: [
          { identifier: "4.1", label: "Agriculture, forestry, and fisheries" },
          { identifier: "4.2", label: "Animal and dairy science" },
          { identifier: "4.3", label: "Veterinary science" },
          { identifier: "4.4", label: "Agricultural biotechnology" },
          { identifier: "4.5", label: "Other agricultural sciences" }
>>>>>>> roadmap-development
        ]
      },
      {
        identifier: "5",
        label: "Social Sciences",
<<<<<<< HEAD
        keywords: "social",
        children: [
          { identifier: "5.1", label: "Psychology", keywords: "behavior cognative conscious deviance mental personality socio psycho" },
          { identifier: "5.2", label: "Economics and business", keywords: "business economic keynesian market marxism politic" },
          { identifier: "5.3", label: "Educational sciences", keywords: "education teacher" },
          { identifier: "5.4", label: "Sociology", keywords: "bereave cultural culture criminal demogr deviance ethnic family gender leisure population poverty punish race religion rural sexual social urban" },
          { identifier: "5.5", label: "Law", keywords: "court ethics judicial jurisprud legal punish" },
          { identifier: "5.6", label: "Political science", keywords: "economic governance government peace politic war" },
          { identifier: "5.7", label: "Social and economic geography", keywords: "diaspor" },
          { identifier: "5.8", label: "Media and communications", keywords: "" },
          { identifier: "5.7", label: "Other social sciences", keywords: "" }
=======
        children: [
          { identifier: "5.1", label: "Psychology" },
          { identifier: "5.2", label: "Economics and business" },
          { identifier: "5.3", label: "Educational sciences" },
          { identifier: "5.4", label: "Sociology" },
          { identifier: "5.5", label: "Law" },
          { identifier: "5.6", label: "Political science" },
          { identifier: "5.7", label: "Social and economic geography" },
          { identifier: "5.8", label: "Media and communications" },
          { identifier: "5.7", label: "Other social sciences" }
>>>>>>> roadmap-development
        ]
      },
      {
        identifier: "6",
        label: "Humanities",
<<<<<<< HEAD
        keywords: "humanit",
        children: [
          { identifier: "6.1", label: "History and archaeology", keywords: "antiqu archaeol archeol excavat history paleontol" },
          { identifier: "6.2", label: "Languages and literature", keywords: "linguist" },
          { identifier: "6.3", label: "Philosophy, ethics and religion", keywords: "aesthetic ethics epistemol metaphysic logic philosophy religion" },
          { identifier: "6.4", label: "Art (arts, history of arts, performing arts, music)", keywords: "" },
          { identifier: "6.5", label: "Other humanities", keywords: "" }
=======
        children: [
          { identifier: "6.1", label: "History and archaeology" },
          { identifier: "6.2", label: "Languages and literature" },
          { identifier: "6.3", label: "Philosophy, ethics and religion" },
          { identifier: "6.4", label: "Art (arts, history of arts, performing arts, music)" },
          { identifier: "6.5", label: "Other humanities" }
>>>>>>> roadmap-development
        ]
      }
    ].each do |fos|
      p "#{fos[:identifier]} - #{fos[:label]}"
<<<<<<< HEAD
      parent = FieldOfScience.find_or_create_by(identifier: fos[:identifier], label: fos[:label],
                                                keywords: fos[:keywords])
      fos[:children].each do |child|
        child[:parent_id] = parent.id
        p "    #{child[:identifier]} - #{child[:label]}"
        FieldOfScience.find_or_create_by(child)
      end
    end
  end

  desc "Fetch the latest RDA Metadata Standards"
  task load_rdamsc_standards: :environment do
    p "Fetching the latest RDAMSC metadata standards and updating the metadata_standards table"
    ExternalApis::RdamscService.fetch_metadata_standards
  end

  desc "Load Repositories from re3data"
  task load_re3data_repos: :environment do
    Rails::Task["v3:init_re3data"].execute unless IdentifierScheme.find_by(name: "rethreedata").present?
    ExternalApis::Re3dataService.fetch
  end

  desc "Load Licenses from SPDX"
  task load_spdx_licenses: :environment do
    ExternalApis::SpdxService.fetch
  end

  desc "Push specified plan to the owners ORCID record if they have authorized the interaction"
  task :add_plan_to_orcid_works, [:id] => [:environment] do |t, args|
    plan = Plan.find_by(id: args[:id])

    if plan.present?
      owner = plan.owner
      orcid = owner.identifier_for_scheme(scheme: "orcid")
      token = ExternalApiAccessToken.for_user_and_service(user: plan.owner, service: "orcid")

      if owner.present? && token.present? && orcid.present?
        # TODO: Although ORCID will prevent suplicate entries, it might be good to add a method
        #       to the OrcidService that checks to see if the work is already there.
        ExternalApis::OrcidService.add_work(user: owner, plan: plan)
        true
      else
        p "Either the plan has no owner or the owner has not authorized us to write to their ORCID record"
        false
      end
    else
      p "Expected a plan id to be specified like `rails external_api:add_plan_to_orcid_works[123]`"
      false
    end
  end
end
=======
      parent = ResearchDomain.find_or_create_by(identifier: fos[:identifier], label: fos[:label])

      fos[:children].each do |child|
        child[:parent_id] = parent.id
        p "    #{child[:identifier]} - #{child[:label]}"
        ResearchDomain.find_or_create_by(child)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength, Layout/LineLength
>>>>>>> roadmap-development
