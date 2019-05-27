# frozen_string_literal

class ArphaUploadService

  include Arphaable

  TEMPLATE_NAME = "arpha/plans/show.xml.erb"

  attr_reader :user
  attr_reader :plan
  attr_reader :link

  delegate :logger, to: :Rails

  def initialize(plan:, user:)
    @plan = plan
    @user = user
  end

  def call
    ##
    # Authenticate user
    authenticate_user

    ##
    # Validate the document before submitting
    validate_document

    ##
    # Submit the document and fetch the link for redirects
    @link = fetch_submission_link
  end

  private

  def authenticate_user
    response = arpha_api_post(action: "authenticate",
                              username: user.arpha_username,
                              api_key: user.arpha_api_key)

    if parse_arpha_xml(xml: response.body, node: "returnCode") == "0"
      logger.info("Successfully authenticated user with Arpha API")
    else
      logger.warn("Couldn't authente user with Arpha API")
    end
  end

  def validate_document
    response = arpha_api_post(action: "validate_document",
                              xml: document_xml)

    if parse_arpha_xml(xml: response.body, node: "returnCode") == "0"
      logger.info "XML docuemnt validated"
    else
      logger.warn "XML Document was invalid!"
    end
  end

  def fetch_submission_link
    response = arpha_api_post(action: "import_document",
                              xml: document_xml,
                              username: @user.arpha_username,
                              api_key: @user.arpha_api_key)
    parse_arpha_xml(xml: response.body, node: "document_autologin_link")
  end

  def document_xml
    @document_xml ||= view.render({
      template: TEMPLATE_NAME,
      layout: false,
      format: "xml"
    })
  end

  def view
    @view ||= ActionView::Base.new(ActionController::Base.view_paths, { plan: plan })
  end

end
