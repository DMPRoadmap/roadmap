# frozen_string_literal: true

<<<<<<< HEAD
class OrgSelectionPresenter

=======
# Helper class for the Org selection typeahead
class OrgSelectionPresenter
>>>>>>> upstream/master
  attr_accessor :suggestions

  def initialize(orgs:, selection:)
    @crosswalk = []

<<<<<<< HEAD
    @name = selection.present? ? selection.name : ""

    if selection.present?
      orgs = [selection] if !orgs.present? || orgs.empty?
    end
=======
    @name = selection.present? ? selection.name : ''

    orgs = [selection] if !orgs.present? || orgs.empty?
>>>>>>> upstream/master

    @crosswalk = orgs.map do |org|
      next if org.nil?

      OrgSelection::OrgToHashService.to_hash(org: org)
    end
  end

  attr_reader :name

  def crosswalk
    @crosswalk.to_json
  end

  def select_list
    @crosswalk.map { |rec| rec[:name] }.to_json
  rescue StandardError
    nil
  end

  def crosswalk_entry_from_org_id(value:)
    return {}.to_json unless value.present? && value.to_s =~ /[0-9]+/

    entry = @crosswalk.select { |item| item[:id].to_s == value.to_s }.first
    entry.present? ? entry.to_json : {}.to_json
  rescue StandardError
    {}.to_json
  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
