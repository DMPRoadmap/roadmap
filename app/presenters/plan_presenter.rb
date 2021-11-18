# frozen_string_literal: true

class PlanPresenter

  attr_accessor :plan

  def initialize(plan)
    @plan = plan
  end

  # Converts the Project Start and End Dates into human readable text
  # rubocop:disable Metrics/AbcSize
  def project_dates_to_readonly_display
    sd = I18n.l(@plan.start_date.to_date, formats: :short) if @plan.start_date.present?
    ed = I18n.l(@plan.end_date.to_date, formats: :short) if @plan.end_date.present?

    return "#{sd} to #{ed}" if sd.present? && ed.present?
    return "Starts on #{sd}" if sd.present?
    return "Ends on #{ed}" if ed.present?

    ""
  end
  # rubocop:enable Metrics/AbcSize

end
