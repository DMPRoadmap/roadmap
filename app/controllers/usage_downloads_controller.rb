# frozen_string_literal: true

class UsageDownloadsController < ApplicationController

  def index
    check_authorized!
    data = Org::TotalCountStatService.call
    data_csvified = Csvable.from_array_of_hashes(data)

    send_data(data_csvified, filename: "totals.csv")
  end

  private

  def check_authorized!
    unless current_user.present? &&
           (current_user.can_org_admin? || current_user.can_super_admin?)
      raise Pundit::NotAuthorizedError
    end
  end

end
