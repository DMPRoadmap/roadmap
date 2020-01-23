# frozen_string_literal: true

class OrgSelectionPresenter

  attr_accessor :suggestions

  def initialize(orgs:, selection:)
    @crosswalk = []

    # TODO: Remove this once the is_other Org has been removed
    @name = selection.present? ? selection.name : ""

    orgs = [selection] if !orgs.present? || orgs.empty?

    @crosswalk = orgs.map do |org|
      next if org.nil?

      OrgSelection::OrgToHashService.to_hash(org: org)
    end
  end

  # Return the Org name unless this is the default is_other Org
  attr_reader :name

  def crosswalk
    @crosswalk.to_json
  end

  def select_list
    @crosswalk.map { |rec| rec[:name] }.to_json
  end

end
