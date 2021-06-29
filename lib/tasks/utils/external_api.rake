# frozen_string_literal: true

namespace :external_api do

  desc "Populate the org_indices table from latest tmp/ror.json (single use) To force it to reprocess you can pass an argument `rails \"external_api:ror_index[true]\"` (Note the quotes)"
  task :ror_index, [:force] => :environment do |_, args|
    p "Proccessing ROR catalog. See log/[env].log for details - #{Time.now.strftime('%H:%m:%S')}"
    ExternalApis::RorService.fetch(force: args[:force])
    p "Complete - #{Time.now.strftime('%H:%m:%S')}"
  end

  desc "Search"
  task ror_search: :environment do
    # TODO: Convert this to a TEST!!!!
=begin
    p "Expecting to find 'UNSW Sydney (unsw.edu.au)' with an acronym of 'UNSW' and alias of 'University of New South Wales'"
    org = OrgIndex.find_by(name: "UNSW Sydney (unsw.edu.au)")
    p "By name 1 - #{OrgIndex.search("UNSW Sydney").include?(org)}"
    p "By name 2 - #{OrgIndex.search("Sydney").include?(org)}"
    p "By domain - #{OrgIndex.search("unsw.edu.au").include?(org)}"
    p "By acronym - #{OrgIndex.by_acronym("UNSW").include?(org)}"
    p "By alias 1 - #{OrgIndex.by_alias("University of New South Wales").include?(org)}"
    p "By alias 2 - #{OrgIndex.by_alias("New South Wales").include?(org)}"
    p "By type - #{OrgIndex.by_type("education").include?(org)}"
    p ""
    p "Searching for 'Berkeley' - #{Time.now.strftime('%H:%m:%S')}"
    results = OrgSelection::NewSearchService.search(term: "Berkeley")
    p "Done:  - #{Time.now.strftime('%H:%m:%S')} - Showing top 5 of #{results.length}"
    pp results.map(&:name)[0..5]
    p ""
    p "Old Way - #{Time.now.strftime('%H:%m:%S')}"
    results = OrgSelection::SearchService.search_combined(search_term: "Berkeley")
    p "Done: - #{Time.now.strftime('%H:%m:%S')}- Showing top 5 of #{results.length}"
    pp results.map { |r| r[:name] }[0..5]
    p ""
    p '============================================================='
    p ""
    p "Searching for 'Berk' - #{Time.now.strftime('%H:%m:%S')}"
    results = OrgSelection::NewSearchService.search(term: "Berk")
    p "Done: - #{Time.now.strftime('%H:%m:%S')}- Showing top 5 of #{results.length}"
    pp results.map(&:name)[0..5]
    p ""
    p "Old Way - #{Time.now.strftime('%H:%m:%S')}"
    results = OrgSelection::SearchService.search_combined(search_term: "Berk")
    p "Done: - #{Time.now.strftime('%H:%m:%S')}- Showing top 5 of #{results.length}"
    pp results.map { |r| r[:name] }[0..5]
    p '============================================================='
=end
    p ""
    s = Time.now
    p "NEW MODEL SEARCH for 'UCB' - #{s.strftime('%H:%m:%S')}"
    results = OrgIndex.search("UCB")
    e = Time.now - s
    p "Done: - #{Time.now.strftime('%H:%m:%S')}- Showing top 10 of #{results.length} (elapsed - #{e})"
    ucb = Org.where(abbreviation: "UCB").first
    p ucb.inspect
    p ucb&.users&.size
    pp results.map { |r| "#{r.users_count} - #{r.name}" }[0..14]
    p ""
    p '============================================================='
    p ""
    s = Time.now
    p "NEW SERVICE SEARCH for 'UCB' - #{s.strftime('%H:%m:%S')}"
    results = OrgSelection::NewSearchService.search(term: "UCB")
    e = Time.now - s
    p "Done: - #{Time.now.strftime('%H:%m:%S')}- Showing top 15 of #{results.length} (elapsed - #{e})"
    pp results.map(&:name)[0..14]
    p ""
    s = Time.now
    p "Old Way - (ROR and DB) #{s.strftime('%H:%m:%S')}"
    results = OrgSelection::SearchService.search_combined(search_term: "UCB")
    e = Time.now - s
    p "Done: - #{Time.now.strftime('%H:%m:%S')}- Showing top 15 of #{results.length} (elapsed - #{e})"
    pp results.map { |r| r[:name] }[0..14]
  end

  desc "Seed the Field of Science (fos) table"
  task load_field_of_science: :environment do
    # TODO: If we can identify an external API authority for this information we should switch
    #       to fetch the list from there instead of the hard-coded list below which was derived from:
    #       https://www.oecd.org/science/inno/38235147.pdf
    [
      {
        identifier: "1",
        label: "Natural sciences",
        keywords: "",
        children: [
          { identifier: "1.1", label: "Mathematics", keywords: "astronomy algebra calcul geometr logic mathematic physics probability statistic topology" },
          { identifier: "1.2", label: "Computer and information sciences", keywords: "artificial computation computer" },
          { identifier: "1.3", label: "Physical sciences", keywords: "astronomy atmospher chemistry crystallography earth electronics materials meteorology ocean physics space thermodynamic" },
          { identifier: "1.4", label: "Chemical sciences", keywords: "chemical chemistry" },
          { identifier: "1.5", label: "Earth and related environmental sciences", keywords: "atmospher biology climate earth ecology environmental meteorology ocean seism" },
          { identifier: "1.6", label: "Biological sciences", keywords: "anatomy biochemistry biodiversity biology botany ecology genetics morphology mycology zoology" },
          { identifier: "1.7", label: "Other natural sciences", keywords: "" }
        ]
      },
      {
        identifier: "2",
        label: "Engineering and Technology",
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
        ]
      },
      {
        identifier: "3",
        label: "Medical and Health Sciences",
        keywords: "anesthes angiology audiology bariatric cardio dental dentist dermatol disease endocrin gastroent geriatric gynecol health hematol hepatol infectious kinesiol laboratory medical medicine neurol nephrol oncolo ophthalm orthop otolaryn patholo pediatric pharmacol pulmonol psychiatr radiolo rheumatol splanchn surgery surgical urolo veterinar",
        children: [
          { identifier: "3.1", label: "Basic medicine", keywords: "" },
          { identifier: "3.2", label: "Clinical medicine", keywords: "" },
          { identifier: "3.3", label: "Health sciences", keywords: "" },
          { identifier: "3.4", label: "Health biotechnology", keywords: "" },
          { identifier: "3.5", label: "Other medical sciences", keywords: "" }
        ]
      },
      {
        identifier: "4",
        label: "Agricultural Sciences",
        keywords: "agricultur biodiversity ecology habitat veterinar",
        children: [
          { identifier: "4.1", label: "Agriculture, forestry, and fisheries", keywords: "aquaculture fisheries fishery forest timber" },
          { identifier: "4.2", label: "Animal and dairy science", keywords: "" },
          { identifier: "4.3", label: "Veterinary science", keywords: "animal veterinar" },
          { identifier: "4.4", label: "Agricultural biotechnology", keywords: "" },
          { identifier: "4.5", label: "Other agricultural sciences", keywords: "" }
        ]
      },
      {
        identifier: "5",
        label: "Social Sciences",
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
        ]
      },
      {
        identifier: "6",
        label: "Humanities",
        keywords: "humanit",
        children: [
          { identifier: "6.1", label: "History and archaeology", keywords: "antiqu archaeol archeol excavat history paleontol" },
          { identifier: "6.2", label: "Languages and literature", keywords: "linguist" },
          { identifier: "6.3", label: "Philosophy, ethics and religion", keywords: "aesthetic ethics epistemol metaphysic logic philosophy religion" },
          { identifier: "6.4", label: "Art (arts, history of arts, performing arts, music)", keywords: "" },
          { identifier: "6.5", label: "Other humanities", keywords: "" }
        ]
      }
    ].each do |fos|
      p "#{fos[:identifier]} - #{fos[:label]}"
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