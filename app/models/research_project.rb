# frozen_string_literal: true

ResearchProject = Struct.new(:grant_id, :description) do
  def to_json(_val = nil)
    { grant_id: grant_id, description: description }.to_json
  end

  def id
    object_id
  end
end
