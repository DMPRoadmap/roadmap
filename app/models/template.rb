class Template < ActiveRecord::Base
  include GlobalHelpers

  ##
  # Associations
  belongs_to :org
  has_many :plans
  has_many :phases
  has_many :sections, through: :phases
  has_many :questions, through: :sections

  has_many :customizations, class_name: 'Template', foreign_key: 'dmptemplate_id'
  belongs_to :dmptemplate, class_name: 'Template'

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  attr_accessible :id, :org_id, :description, :published, :title, :locale, 
                  :is_default, :guidance_group_ids, :org, :plans, :phases, 
                  :version, :visibility, :published, :as => [:default, :admin]

  # defines the export setting for a template object
  has_settings :export, class_name: 'Settings::Template' do |s|
    s.key :export, defaults: Settings::Template::DEFAULT_SETTINGS
  end

  validates :org, :title, :version, presence: true

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?



  ##
  # takes a type or organisation and returns all published templates from
  # organisations of that type
  #
  # @param ot [String] name of an organisation type e.g. founder
  # @return [Array<dmptemplates>] list of published dmptemplates
=begin
  def self.templates_org_type(ot)
    # DISCUSS - This function other than the check for the template being published
    # is a superclass for the below funders_templates
    new_org_obejcts = OrganisationType.find_by( name: ot ).organisations

    org_templates = Array.new
    new_org_obejcts.each do |neworg|
       org_templates += neworg.dmptemplates.where("published = ?", true)
    end

    return org_templates
  end

  ##
  # returns all templates from all organisations of the Organisation_Type funder
  #
  # @return [Array<dmptemplates>] all templates from funder organisations
  def self.funders_templates
    funder_orgs = Org.includes(:templates).funder
    org_templates = Array.new

    funder_orgs.each do |neworg|
      org_templates += neworg.templates
    end

    return org_templates
  end

  ##
  # returns all institutional templates bellowing to the given organisation
  #
  # @param org_id [integer] the integer id for an organisation
  # @return [Array<dmptemplates>] all templates from a user's organisation
  def self.own_institutional_templates(org_id)
    # DISCUSS - Why is this done by scanning organisation_id's from the templates
    # yet all other calls are done by finding an organisation, and using the
    # has_many relationship to find the dmptemplates?
    # - A possible answer is that there may be deleted organisations which we are
    # serching for templates for.
    # - A standardised behavior on querries, wether through active reccord or the
    # where, should maybe be thought of/decided upon
    new_templates = self.where("org_id = ?", org_id)
    return new_templates
  end
  
  ##
  # returns an array with all funders and of the given organisations's
  # institutional templates
  #
  # @param org_id [integer] the integer id for an organisation
  # @return [Array<dmptemplates>] all templates from the template's organisation
  #   or from a funder organisation
  def self.funders_and_own_templates(org_id)
    funders_templates = self.funders_templates

    #verify if org type is not a funder
    current_org = Org.find(org_id)
    if !current_org.funder? then
      own_institutional_templates = self.own_institutional_templates(org_id)
    else
      own_institutional_templates = []
    end

    templates_list = Array.new
    templates_list += own_institutional_templates
    templates_list += funders_templates
    templates_list = templates_list.sort_by { |f| f['title'].downcase }

    return templates_list
  end
  
  ##
  # Returns the string name of the organisation type of the organisation who
  # owns this dmptemplate
  #
  # @return [string] the string name of an organisation type
  def org_type
    org_type = org.organisation_type
    return org_type
  end
=end
  
  ##
  # Verify if a template has customisation by given organisation
  #
  # @param org_id [integer] the integer id for an organisation
  # @param temp [dmptemplate] a template object
  # @return [Boolean] true if temp has customisation by the given organisation
  def has_customisations?(org_id, temp)
    modifiable = true
    phases.each do |phase|
      modifiable = modifable && phase.modifiable
    end
    return !modifiable
    # if temp.org_id != org_id then
    #   temp.phases.each do |phase|
    #     phase.versions.each do |version|
    #       version.sections.each do |section|
    #         return true if section.organisation_id == org_id
    #       end
    #     end
    #     return false
    #   end
    # else
    #   return false
    # end
  end

=begin
  ##
  # verify if there are any publish version for the template
  #
  # @return [Boolean] true if there is a published version for the template
  def has_published_versions?
    phases.each do |phase|
      return true if !phase.latest_published_version.nil?
    end
    return false 
  end
=end
  
  # OLD CODE STARTS HERE

end
