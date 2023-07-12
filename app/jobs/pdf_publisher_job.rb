# frozen_string_literal: true

# This Job sends a notification (the JSON version of the Plan) out to the specified
# subscriber.
class PdfPublisherJob < ApplicationJob
  queue_as :default

  def perform(plan:)
    if plan.is_a?(Plan)
      ac = ApplicationController.new # ActionController::Base.new
      html = ac.render_to_string(template: 'branded/shared/export/pdf', layout: false, locals: _prep_for_pdf(plan: plan))
      pdf = WickedPdf.new.pdf_from_string(html)

      # limit the filename length to 100 chars. Windows systems have a MAX_PATH allowance
      # of 255 characters, so this should provide enough of the title to allow the user
      # to understand which DMP it is and still allow for the file to be saved to a deeply
      # nested directory
      file_name = Zaru.sanitize!(plan.title).strip.gsub(/\s+/, '_')[0, 100]
      _process_narrative_file(plan: plan, file_name: file_name, file: pdf)
    elsif plan.is_a?(Dmp)
      return false unless plan.narrative.attached?

      # plan.narrative.open { |file| Rails.logger.info "FILE: #{file.path}"; _process_narrative_file(plan: plan, file_name: file.path, file: file) }

      # Pull the PDF from ActiveStorage and save to a tmp file for upload to the DMPHub
      pdf = plan.narrative.download
      file_name = Zaru.sanitize!(plan.metadata['dmp']['title']).strip.gsub(/\s+/, '_')[0, 100]
      _process_narrative_file(plan: plan, file_name: file_name, file: pdf)
    else
      Rails.logger.error 'PdfPublisherJob.perform expected a Plan!'
      false
    end
  rescue StandardError => e
    # Something went terribly wrong, so note it in the logs since this runs outside the
    # regular Rails thread that the application is using
    Rails.logger.error "PdfPublisherJob.perform failed for Plan: #{plan&.id} - #{e.message}"
    Rails.logger.error e.backtrace
  end

  private

  # Build a copy of the narrative PDF and then send it to the DmpIdService
  def _process_narrative_file(plan:, file_name:, file:)
    # Write the file to the tmp directory for the upload process
    pdf_file_name = Rails.root.join('tmp', "#{file_name}.pdf")
    pdf_file = File.open(pdf_file_name, 'wb') { |tmp| tmp << file }
    pdf_file.close

puts "        Publishing #{pdf_file_name}"

    DmpIdService.publish_pdf(plan: plan, pdf_file_name: pdf_file_name)
    # Delete the tmp file
    File.delete(pdf_file_name)
  end

  # rubocop:disable Metrics/AbcSize
  def _prep_for_pdf(plan:)
    return {} if plan.blank?

    {
      plan: plan,
      public_plan: plan.publicly_visible?,
      hash: plan.as_pdf(nil, true),
      formatting: plan.settings(:export).formatting || plan.template.settings(:export).formatting,
      selected_phase: plan.phases.order('phases.updated_at DESC').first
    }
  end
  # rubocop:enable Metrics/AbcSize
end
