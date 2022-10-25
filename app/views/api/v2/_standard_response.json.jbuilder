# frozen_string_literal: true

# locals: response, request, total_items

total_items ||= 0
path = @scope.present? ? "#{request.path}?scope=#{@scope}" : request.path
paginator = Api::V1::PaginationPresenter.new(current_url: path,
                                             per_page: @per_page,
                                             total_items: total_items,
                                             current_page: @page)

json.prettify!
json.ignore_nil!

json.application @application
json.api_version 2
json.source "#{request.method} #{request.path}"
json.time Time.zone.now.to_formatted_s(:iso8601)
json.caller @caller
json.code response.status
json.message Rack::Utils::HTTP_STATUS_CODES[response.status]

# Pagination Links
if total_items.positive?
  json.page @page
  json.per_page @per_page
  json.total_items total_items

  # Prepare the base URL by removing the old pagination params
  json.prev paginator.prev_page_link if paginator.prev_page?
  json.next paginator.next_page_link if paginator.next_page?
else
  json.total_items 0
end
