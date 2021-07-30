# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength, Layout/LineLength
namespace :external_api do
  desc "Seed the Research Domain table with Field of Science categories"
  task add_field_of_science_to_research_domains: :environment do
    # TODO: If we can identify an external API authority for this information we should switch
    #       to fetch the list from there instead of the hard-coded list below which was derived from:
    #       https://www.oecd.org/science/inno/38235147.pdf
    [
      {
        identifier: "1",
        label: "Natural sciences",
        children: [
          { identifier: "1.1", label: "Mathematics" },
          { identifier: "1.2", label: "Computer and information sciences" },
          { identifier: "1.3", label: "Physical sciences" },
          { identifier: "1.4", label: "Chemical sciences" },
          { identifier: "1.5", label: "Earth and related environmental sciences" },
          { identifier: "1.6", label: "Biological sciences" },
          { identifier: "1.7", label: "Other natural sciences" }
        ]
      },
      {
        identifier: "2",
        label: "Engineering and Technology",
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
        ]
      },
      {
        identifier: "3",
        label: "Medical and Health Sciences",
        children: [
          { identifier: "3.1", label: "Basic medicine" },
          { identifier: "3.2", label: "Clinical medicine" },
          { identifier: "3.3", label: "Health sciences" },
          { identifier: "3.4", label: "Health biotechnology" },
          { identifier: "3.5", label: "Other medical sciences" }
        ]
      },
      {
        identifier: "4",
        label: "Agricultural Sciences",
        children: [
          { identifier: "4.1", label: "Agriculture, forestry, and fisheries" },
          { identifier: "4.2", label: "Animal and dairy science" },
          { identifier: "4.3", label: "Veterinary science" },
          { identifier: "4.4", label: "Agricultural biotechnology" },
          { identifier: "4.5", label: "Other agricultural sciences" }
        ]
      },
      {
        identifier: "5",
        label: "Social Sciences",
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
        ]
      },
      {
        identifier: "6",
        label: "Humanities",
        children: [
          { identifier: "6.1", label: "History and archaeology" },
          { identifier: "6.2", label: "Languages and literature" },
          { identifier: "6.3", label: "Philosophy, ethics and religion" },
          { identifier: "6.4", label: "Art (arts, history of arts, performing arts, music)" },
          { identifier: "6.5", label: "Other humanities" }
        ]
      }
    ].each do |fos|
      p "#{fos[:identifier]} - #{fos[:label]}"
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
