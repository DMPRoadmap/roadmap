# frozen_string_literal: true

module Api

  module V1

    class PaginationPresenter

      def initialize(current_url:, per_page:, total_items:, current_page: 1)
        @url = current_url
        @per_page = per_page
        @total_items = total_items
        @page = current_page
      end

      def url_without_pagination
        return nil unless @url.present? && @url.is_a?(String)

        url = @url.gsub(/per_page=\d+/, "")
                  .gsub(/page=\d+/, "")
                  .gsub(/(&)+$/, "").gsub(/\?$/, "")

        (url.include?("?") ? "#{url}&" : "#{url}?")
      end

      def prev_page?
        total_pages > 1 && @page != 1
      end

      def next_page?
        total_pages > 1 && @page < total_pages
      end

      def prev_page_link
        "#{url_without_pagination}page=#{@page - 1}&per_page=#{@per_page}"
      end

      def next_page_link
        "#{url_without_pagination}page=#{@page + 1}&per_page=#{@per_page}"
      end

      private

      def total_pages
        return 1 unless @total_items.present? && @per_page.present? &&
                        @total_items.positive? && @per_page.positive?

        (@total_items.to_f / @per_page).ceil
      end

    end

  end

end
