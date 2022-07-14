# frozen_string_literal: true

# Controller to handle CRUD operations for the Research Outputs tab
class ResearchOutputsController < ApplicationController
  helper PaginableHelper

  before_action :fetch_plan, except: %i[select_output_type select_license repository_search
                                        metadata_standard_search]
  before_action :fetch_research_output, only: %i[edit update destroy]

  after_action :verify_authorized

  # GET /plans/:plan_id/research_outputs
  def index
    @research_outputs = ResearchOutput.includes(:repositories)
                                      .where(plan_id: @plan.id)
    authorize @research_outputs.first || ResearchOutput.new(plan_id: @plan.id)
  end

  # GET /plans/:plan_id/research_outputs/new
  def new
    @research_output = ResearchOutput.new(plan_id: @plan.id, output_type: '')
    authorize @research_output
  end

  # GET /plans/:plan_id/research_outputs/:id/edit
  def edit
    authorize @research_output
  end

  # POST /plans/:plan_id/research_outputs
  def create
    args = process_byte_size.merge({ plan_id: @plan.id })
    args = process_nillable_values(args: args)
    @research_output = ResearchOutput.new(args)
    authorize @research_output

    if @research_output.save
      redirect_to plan_research_outputs_path(@plan),
                  notice: success_message(@research_output, _('added'))
    else
      flash[:alert] = failure_message(@research_output, _('add'))
      render 'research_outputs/new'
    end
  end

  # PATCH/PUT /plans/:plan_id/research_outputs/:id
  # rubocop:disable Metrics/AbcSize
  def update
    args = process_byte_size.merge({ plan_id: @plan.id })
    args = process_nillable_values(args: args)
    authorize @research_output

    # Clear any existing repository and metadata_standard selections.
    @research_output.repositories.clear
    @research_output.metadata_standards.clear

    if @research_output.update(args)
      redirect_to plan_research_outputs_path(@plan),
                  notice: success_message(@research_output, _('saved'))
    else
      redirect_to edit_plan_research_output_path(@plan, @research_output),
                  alert: failure_message(@research_output, _('save'))
    end
  end
  # rubocop:enable Metrics/AbcSize

  # DELETE /plans/:plan_id/research_outputs/:id
  def destroy
    authorize @research_output

    if @research_output.destroy
      redirect_to plan_research_outputs_path(@plan),
                  notice: success_message(@research_output, _('removed'))
    else
      redirect_to plan_research_outputs_path(@plan),
                  alert: failure_message(@research_output, _('remove'))
    end
  end

  # ============================
  # = Rails UJS remote methods =
  # ============================

  # GET  /plans/:id/output_type_selection
  def select_output_type
    @plan = Plan.find_by(id: params[:plan_id])
    @research_output = ResearchOutput.new(
      plan: @plan, output_type: output_params[:output_type]
    )
    authorize @research_output
  end

  # GET  /plans/:id/license_selection
  def select_license
    @plan = Plan.find_by(id: params[:plan_id])
    @research_output = ResearchOutput.new(
      plan: @plan, license_id: output_params[:license_id]
    )
    authorize @research_output
  end

  # GET /plans/:id/repository_search
  # rubocop:disable Metrics/AbcSize
  def repository_search
    @plan = Plan.find_by(id: params[:plan_id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output

    @search_results = Repository.by_type(repo_search_params[:type_filter])
    @search_results = @search_results.by_subject(repo_search_params[:subject_filter])
    @search_results = @search_results.search(repo_search_params[:search_term])

    @search_results = @search_results.order(:name).page(params[:page])
  end
  # rubocop:enable Metrics/AbcSize

  # PUT /plans/:id/repository_select
  def repository_select
    @plan = Plan.find_by(id: params[:plan_id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output

    @research_output
  end

  # PUT /plans/:id/repository_unselect
  def repository_unselect
    @plan = Plan.find_by(id: params[:plan_id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output
  end

  # GET /plans/:id/metadata_standard_search
  def metadata_standard_search
    @plan = Plan.find_by(id: params[:plan_id])
    @research_output = ResearchOutput.new(plan: @plan)
    authorize @research_output

    @search_results = MetadataStandard.search(metadata_standard_search_params[:search_term])
                                      .order(:title)
                                      .page(params[:page])
    
      ### Valid Format
      # m = MetadataStandard.create!(
      #   :title=> "MIBBI (Minimum Information for Biological and Biom...", 
      #   :description=> "<p>A common portal to a group of nearly 40 checkli...", 
      #   :rdamsc_id=> "msc:m23", 
      #   :uri=> "https://rdamsc.bath.ac.uk/api2/m23", 
      #   :locations=> [{"url"=>"http://mibbi.sourceforge.net/foundry.shtml", "type"=>"document"}.to_json, {"url"=>"http://mibbi.sourceforge.net/portal.shtml", "type"=>"website"}.to_json], 
      #   :related_entities => [{"id"=>"msc:m72", "role"=>"child scheme"}.to_json, {"id"=>"msc:t50", "role"=>"tool"}.to_json], 
      #   :created_at=> "2022-06-30 20:05:58", "updated_at"=> "2022-06-30 22:00:38"
      # )
      
     ### Debug: test hard-coded item    

    p "%%%%%%%%%%%%%here"
    # @search_results = MetadataStandard.where(title: [m].map(&:title)).order(:title).page(params[:page])
    p @search_results.first.locations.class # local: array, docker:string [need transfer to array of json]

    # get each active record and update its location attribute
    @search_results.each do |sr|
      
      # transfer location
      # if sr.locations.is_a? String
        p "%%%%%%%%%%into transfer"
        l_arr = sr.locations.to_s.tr('[', '').tr(']', '').split('},')
        puts l_arr
        l_arr_new = []
        l_arr.each do|json_str|
          #json_str = json_str # add the missing } back
          json_str = "{:url=>\"http://mibbi.sourceforge.net/foundry.shtml\", :type=>\"document\"}", "{:url=>\"http://mibbi.sourceforge.net/portal.shtml\", :type=>\"website\"}"
          json_str = json_str.to_s
          puts json_str.gsub(/[{}:]/,'')
          puts json_str.gsub(/[{}:]/,'').split(', ')
          puts json_str.gsub(/[{}:]/,'').split(', ').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
          json_str = json_str.gsub(/[{}:]/,'').split(', ').map{|h| h1,h2 = h.split('=>'); {h1 => h2}}.reduce(:merge)
          l_arr_new.push(json_str)
        
        #end
        sr.locations = l_arr_new
        puts "now result is:" 
        p sr.locations
      end
      ### Pending for related entities
    end
    p @search_results.first.locations
    respond_to do |format|
      format.js
    end
  end

  private

  def output_params
    params.require(:research_output)
          .permit(%i[title abbreviation description output_type output_type_description
                     sensitive_data personal_data file_size file_size_unit mime_type_id
                     release_date access coverage_start coverage_end coverage_region
                     mandatory_attribution license_id],
                  repositories_attributes: %i[id], metadata_standards_attributes: %i[id])
  end

  def repo_search_params
    params.require(:research_output).permit(%i[search_term subject_filter type_filter])
  end

  def metadata_standard_search_params
    p "%%%metadata_standard_search_params"
    p params
    params.require(:research_output).permit(%i[search_term])
  end

  # rubocop:disable Metrics/AbcSize
  def process_byte_size
    args = output_params

    if args[:file_size].present?
      byte_size = 0.bytes + case args[:file_size_unit]
                            when 'pb'
                              args[:file_size].to_f.petabytes
                            when 'tb'
                              args[:file_size].to_f.terabytes
                            when 'gb'
                              args[:file_size].to_f.gigabytes
                            when 'mb'
                              args[:file_size].to_f.megabytes
                            else
                              args[:file_size].to_i
                            end

      args[:byte_size] = byte_size
    end

    args.delete(:file_size)
    args.delete(:file_size_unit)
    args
  end
  # rubocop:enable Metrics/AbcSize

  # There are certain fields on the form that are visible based on the selected output_type. If the
  # ResearchOutput previously had a value for any of these and the output_type then changed making
  # one of these arguments invisible, then we need to blank it out here since the Rails form will
  # not send us the value
  def process_nillable_values(args:)
    args[:byte_size] = nil unless args[:byte_size].present?
    args
  end

  # =============
  # = Callbacks =
  # =============

  def fetch_plan
    @plan = Plan.find_by(id: params[:plan_id])
    return true if @plan.present?

    redirect_to root_path, alert: _('plan not found')
  end

  def fetch_research_output
    @research_output = ResearchOutput.includes(:repositories)
                                     .find_by(id: params[:id])
    return true if @research_output.present? &&
                   @plan.research_outputs.include?(@research_output)

    redirect_to plan_research_outputs_path, alert: _('research output not found')
  end
end