# frozen_string_literal: true

# Validation to ensure that an end date must come after a begin/start date
class AfterValidator < ActiveModel::EachValidator
  DEFAULT_MESSAGE = _('must be after %<date>s')

  # rubocop:disable Metrics/AbcSize
  def validate_each(record, attribute, value)
    return if value.nil?
    return if record.persisted? && options[:on].to_s == 'create'
    return if record.new_record? && options[:on].to_s == 'update'

    msg = options.fetch(:message, format(DEFAULT_MESSAGE, date: options[:date]))
    record.errors.add(attribute, msg) if value.to_date < options[:date]
  end
  # rubocop:enable Metrics/AbcSize
end
