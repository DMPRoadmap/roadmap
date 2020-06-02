# frozen_string_literal

class ResearchProject < Struct.new(:grant_id, :description)

  def to_json(val = nil)
    { grant_id: grant_id, description: description }.to_json
  end

  def id
    object_id
  end

end
