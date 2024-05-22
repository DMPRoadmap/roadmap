# frozen_string_literal: true

json.partial! 'api/v2/standard_response', total_items: @total_items

json.items @items do |item|
  if item.is_a?(Plan)
    json.dmp do
      json.partial! 'api/v2/plans/show', plan: item
    end
  elsif item.is_a?(Draft)
    draft = item.dmp_id.nil? ? item.metadata : DmpIdService.fetch_dmp_id(dmp_id: item.dmp_id)
    dmp = draft.is_a?(Hash) ? draft['dmp'] : {}

    url = api_v3_draft_url(item.id).gsub('/v3/drafts/', '/v2/plans/')
                                     .gsub(item.id.to_s, "d_#{item.id}")

    if dmp['dmp_id'].nil?
      dmp['dmp_id'] = JSON.parse({ type: 'url', identifier: url }.to_json)
    end

    dmp.delete('draft_data')

    links = { get: url }
    links[:download] = item.send(:safe_narrative_url) if item.narrative.attached?
    dmp['dmproadmap_links'] = JSON.parse(links.to_json)

    json.dmp item.metadata['dmp']
  end
end
