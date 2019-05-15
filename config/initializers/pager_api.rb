# Use this module to configure pager the available options
#
# Made with love by @icalialabs

PagerApi.setup do |config|

  # Pagination Handler
  # User this option to meet your pagination handler, whether is :kaminari or :will_paginate
  config.pagination_handler = :kaminari

  # Includes Pagination information on Meta
  #
  # config.include_pagination_on_meta = true

  # Includes Pagination information on a Link Header
  #
  config.include_pagination_headers = true

  # Set the Total-Pages Header name
  config.total_pages_header = "X-Total-Pages"

  # Set the Total-Count Header name
  config.total_count_header = "X-Total-Count"
end
