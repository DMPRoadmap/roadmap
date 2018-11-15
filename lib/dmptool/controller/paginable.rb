# frozen_string_literal: true

module Dmptool::Controller::Paginable

  # /paginable/orgs/public/:page
  def public
    ids = Org.where("#{Org.organisation_condition} OR #{Org.institution_condition}")
             .pluck(:id)
    paginable_renderise(
      partial: 'public',
      controller: 'paginable/dmptool/orgs',
      scope: Org.participating.where(id: ids),
      query_params: {
        sort_field: 'orgs.name',
        sort_direction: :asc
      }
    )
  end

end
