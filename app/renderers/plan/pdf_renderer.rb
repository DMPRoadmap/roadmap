# frozen_string_literal

# Render a Plan record as a PDF file
class Plan::PdfRenderer

  require 'wicked_pdf'

  include ActionView::Helpers::RenderingHelper

  ##
  # Default font size for the PDF
  FONT_SIZE = 8

  ENCODING = "UTF-8"

  DEFAULT_OPTIONS = {
    font_size: FONT_SIZE,
    right: "[page] of [topage]",
    encoding: ENCODING,
  }


  attr_reader :plan

  attr_reader :options

  attr_reader :formatting

  attr_reader :show_coversheet

  attr_reader :show_sections_questions

  attr_reader :show_unanswered

  attr_reader :show_custom_sections

  attr_reader :public_plan

  attr_reader :selected_phase


  # Create a new PdfRenderer
  #
  # plan - The Plan we're creating a new PDF for
  #
  # options - Hash of options (default: {}):
  #           :selected_phase  -         The Phase we've selected to display.
  #           :show_coversheet -         Should the PDF include the cover sheet
  #                                      (optional).
  #           :show_sections_questions - Should the PDF show the sections questions
  #                                      (optional).
  #           :show_unanswered -         Should the PDF show unanswered questions
  #                                      (optional).
  #           :show_custom_sections -    Should the PDF show custom sections (optional).
  #           :public_plan -             Is this a public Plan? (optional).
  #           :font_size -               Integer with PDF font size (default: 8).
  def initialize(plan, **options)
    @plan    = plan
    @options = options
    options[:font_size] = options.dig(:formatting, :font_size) || FONT_SIZE
    options.reverse_merge!(DEFAULT_OPTIONS)

    # Set template variables passed in from the controller
    @selected_phase          = options.delete(:selected_phase)
    raise "You must select a phase" if selected_phase.nil?
    @show_coversheet         = !!options.delete(:show_coversheet)
    @show_sections_questions = !!options.delete(:show_sections_questions)
    @show_unanswered         = !!options.delete(:show_unanswered)
    @show_custom_sections    = !!options.delete(:show_custom_sections)
    @public_plan             = !!options.delete(:public_plan)
    @formatting = options.delete(:formatting) || @plan.settings(:export).formatting

    @options.reverse_merge!({
      margin: @formatting,
      spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
      footer: {
        center: _("Created using %{application_name}. Last modified %{date}") % {
          application_name: Rails.configuration.branding[:application][:name],
          date: I18n.l(@plan.updated_at.to_date, format: :readable)
        },
      }
    })
  end

  # The PDF content as a PDF
  #
  # Returns String
  def body
    @pdf_content ||= WickedPdf.new.pdf_from_string(html_content, options)
  end

  alias to_pdf body

  # The PDF content as HTML
  #
  # Returns String
  def html_content
    @html_content ||= begin
      view = ActionView::Base.new(ActionController::Base.view_paths, {})
      view.extend(ExportsHelper)
      view.assign(formatting: formatting)
      view.assign(hash: plan.as_pdf(show_coversheet))
      view.assign(plan: plan)
      view.assign(selected_phase: selected_phase)
      view.assign(show_coversheet: show_coversheet)
      view.assign(show_sections_questions: show_sections_questions)
      view.assign(show_unanswered: show_unanswered)
      view.assign(show_custom_sections: show_custom_sections)
      view.assign(public_plan: public_plan)
      view.render(file: 'public_pages/plan_export.pdf.erb')
    end
  end

  # The name of the PDF file we're creating
  #
  # Returns String
  def file_name
    "#{plan.title}.pdf"
  end

  # NOTE: We're using File instead of Tempfile here, since the object is being sent to
  # a third party API using the RestClient library. T
  #
  # Returns File
  def tmp_file
    @tmp_file ||= begin
      f = File.open(tmp_file_path, 'w', encoding: ENCODING)
      f.binmode
      f.write(body)
      f.close
      File.open(tmp_file_path, 'r', encoding: ENCODING)
    end
  end

  alias create_tmp_file tmp_file

  # Remove the temporary file we created in {tmp_file}
  #
  # Returns Integer
  def destroy_tmp_file!
    File.delete(tmp_file_path)
  end

  private

  def tmp_file_path
    ensure_tmp_dir_exists!
    File.join(tmp_dir, file_name)
  end

  def tmp_dir
    Rails.root.join("tmp", "pdfs")
  end

  def ensure_tmp_dir_exists!
    FileUtils.mkdir(tmp_dir) unless Dir.exists?(tmp_dir)
  end

end
