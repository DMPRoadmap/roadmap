# frozen_string_literal: true
class AfterValidator < ActiveModel::EachValidator

  DEFAULT_MESSAGE = _("must be after %{date}")

  def validate_each(record, attribute, value)
    return if value.nil?
    return if record.persisted? && options[:on].to_s == 'create'
    return if record.new_record? && options[:on].to_s == 'update'
    date = options[:date]
    msg  = options.fetch(:message, DEFAULT_MESSAGE % { date: options[:date] })
    record.errors.add(attribute, msg) if value.to_date < options[:date]
  end
end
