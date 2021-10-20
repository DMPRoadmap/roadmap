# frozen_string_literal: true

module DmptoolHelper

  def auth_has_error?(attribute)
    return false unless attribute.present? && @user.present? &&
                        @errors.present? && @errors.any?

    case attribute.to_sym
    when :org, :org_id
      @errors.select { |err| err.start_with?("Institution") }.any?
    when :accept_terms
      @errors.select { |err| err.include?("accept the terms") }.any?
    else
      @errors.select { |err| err.start_with?(attribute.to_s.humanize) }.any?
    end
  end

end
