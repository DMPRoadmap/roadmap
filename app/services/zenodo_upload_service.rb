# frozen_string_literal

class ZenodoUploadService

  require "rest_client"

  ##
  # Headers for JSON requests
  JSON_HEADERS = { 'Content-Type' => 'application/json' }.freeze

  ##
  # Headers for multipart requests
  MULTIPART_HEADERS = { 'Content-Type' => 'multipart/form-data' }.freeze

  attr_reader :user

  attr_reader :plan

  def initialize(plan:, user:)
    @plan = plan
    @user = user
  end

  def call
    # Create a new Deposition on the Zenodo API
    response = create_deposition_on_api!

    # Grab the API's JSON response
    @deposition_id = Oj.load(response.body)['id']
    @plan.update!(zenodo_id: @deposition_id)
    create_file_on_api!
    # Return true
    true
  end

  private

  def selected_phase
    @selected_phase ||= begin
      _sp = plan.phases.order("phases.updated_at DESC")
                      .detect { |p| p.visibility_allowed?(plan) }
      _sp ||= plan.phases.first
    end
  end

  def formatting
    plan.settings(:export).formatting
  end

  def pdf_renderer
    @pdf_renderer ||= Plan::PdfRenderer.new(plan, {
      selected_phase: selected_phase,
      formatting: formatting,
      show_coversheet: true,
      show_sections_questions: true,
      show_unanswered: true,
      show_custom_sections: true,
      public_plan: true,
    })
  end

  def create_deposition_on_api!
    RestClient.post("#{Zenodo::BASE}/api/deposit/depositions"\
                               "?access_token=#{access_token}", {
      title: plan.title,
      metadata: {
        upload_type: "other",
        publication_type: "other",
        publication_date: plan.created_at.iso8601,
        title: plan.title,
        description: plan.description.presence || plan.title,
        grants: [ {id: plan.grant_number }],
      },
    }.to_json, JSON_HEADERS)
  end

  def create_file_on_api!
    begin
      # Create a file on the local disk for the PDF...
      pdf_renderer.create_tmp_file
      # Post this file our newly created Deposition...
      url = "#{BASE}/api/deposit/depositions/#@deposition_id/files"\
              "?access_token=#{user.zenodo_access_token}"
      response = RestClient.post(url, { file: pdf_renderer.tmp_file }, {
        params: {
          filename: pdf_renderer.file_name,
          'Content-Type' => 'multipart/form-data'
        }
      })
      # Nomatter what, destroy the new file
    ensure
      pdf_renderer.destroy_tmp_file!
    end
  end

  def access_token
    user.zenodo_access_token
  end

end
