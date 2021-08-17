# frozen_string_literal: true

# DMPTool specific Rake tasks
namespace :dmptool_specific do

  # We sent the maDMP PRs over to DMPRoadmap after they had been live in DMPTool for some time
  # This script moves the re3data URLs which we original stored in the :identifiers table
  # over to the repositories.uri column
  desc "Moves the re3data ids from :identifiers to :repositories.uri"
  task transfer_re3data_ids: :environment do
    re3scheme = IdentifierScheme.find_by(name: "rethreedata")
    if re3scheme.present?
      Identifier.by_scheme_name(re3scheme, "Repository").each do |identifier|
        repository = identifier.identifiable
        if repository.present? && identifier.value.present?
          repository.update(uri: identifier.value)
        end
        identifier.destroy
      end
    end
  end

end
