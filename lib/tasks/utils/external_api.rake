# frozen_string_literal: true

require "httparty"

# rubocop:disable Metrics/BlockLength
namespace :external_api do
  # MIME Types
  # -------------------------------------
  desc "Fetch all of the latest MIME types and load into the DB"
  task load_mime_types: :environment do
    %w[application.csv audio.csv font.csv image.csv message.csv model.csv
       multipart.csv text.csv video.csv].each do |file_name|
      url = "https://www.iana.org/assignments/media-types"
      fetch_and_process_mime_type_file(url: "#{url}/#{file_name}")
    end
  end

  private

  # MIME Types
  # -------------------------------------
  def fetch_and_process_mime_type_file(url:)
    p "Processing #{url}"
    body = fetch_mime_type_csv_file(url: url)
    p "  Unable to process the specified URL" unless body.present?

    csv = CSV.parse(body, headers: true, force_quotes: true, encoding: "iso-8859-1:utf-8")
    # rubocop:disable Layout/LineLength
    p "  Invalid CSV format. Expecting a 'Name' and 'Template' column" unless csv.headers.include?("Name") &&
                                                                              csv.headers.include?("Template")
    # rubocop:enable Layout/LineLength
    process_mime_type_file(csv: csv)
    p "  Done"
  rescue StandardError => e
    p "  Error processing CSV content - #{e.message}"
  end

  def process_mime_type_file(csv:)
    return unless csv.is_a?(CSV::Table)

    csv.each do |line|
      next unless line["Template"].present? && line["Name"].present?

      type = MimeType.find_or_initialize_by(value: line["Template"].downcase)
      type.description = line["Name"]
      type.category = line["Template"].split("/").first.downcase
      type.save
    end
  end

  def fetch_mime_type_csv_file(url:)
    return nil unless url.present?

    payload = HTTParty.get(url, debug: false)
    return nil unless payload.code == 200

    payload.body
  end
end
# rubocop:enable Metrics/BlockLength
