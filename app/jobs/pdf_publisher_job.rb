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
    elsif plan.is_a?(Draft)
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

    # Send it to DMPHub if it has a DMP ID otherwise store it in local ActiveStorage
    has_dmp_id = plan.dmp_id.present?
    _publish_to_dmphub(plan: plan, pdf_file_name: pdf_file_name) if has_dmp_id
    _publish_locally(plan: plan, pdf_file_path: pdf_file_name, pdf_file_name: "#{file_name}.pdf") if plan.publicly_visible? &&
                                                                                                     !has_dmp_id
    # Delete the tmp file
    File.delete(pdf_file_name)
  end

  # Publish the PDF to local ActiveStorage
  def _publish_locally(plan:, pdf_file_path:, pdf_file_name:)
    # Rails.logger.debug("ActiveStorage using the '#{Rails.configuration.active_storage.service}' service for bucket: '#{Rails.configuration.x.dmproadmap.dragonfly_bucket}'")

    plan.narrative.attach(key: "narratives/#{pdf_file_name}", io: File.open(pdf_file_path), filename: pdf_file_name,
                          content_type: 'application/pdf')
    # Skip updating the timestamps so that it does not re-trigger the callabcks again!
    if plan.save(touch: false)
      Rails.logger.info "PdfPublisherJob._publish_locally successfully published PDF for #{plan.dmp_id} at #{pdf_file_path}"
      plan.publisher_job_status = 'success'
      plan.save(touch: false)
    else
      Rails.logger.error 'PdfPublisherJob._publish_locally failed to store file in ActiveStorage!'
      plan.publisher_job_status = 'failed'
      plan.save(touch: false)
    end
  end

  # Publish the PDF to the DMPHub
  def _publish_to_dmphub(plan:, pdf_file_name:)
    hash = DmpIdService.publish_pdf(plan: plan, pdf_file_name: pdf_file_name)
    if hash.is_a?(Hash) && hash[:narrative_url].present?
      Rails.logger.info "PdfPublisherJob._publish_to_dmphub successfully published PDF for #{plan.dmp_id} at #{hash[:narrative_url]}"
      # Skip updating the timestamps so that it does not re-trigger the callabcks again!
      plan.publisher_job_status = 'success'
      plan.save(touch: false)
    else
      Rails.logger.error 'PdfPublisherJob._publish_to_dmphub did not return a narrtive URL!'
      # Skip updating the timestamps so that it does not re-trigger the callabcks again!
      plan.publisher_job_status = 'failed'
      plan.save(touch: false)
    end
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
