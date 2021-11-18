class JsonValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    record.errors[attribute] << 'is not valid json' unless is_valid_json?(value)
  end

  private

  def is_valid_json?(value)
    !!JSON.load(value)
  rescue
    false
  end

end