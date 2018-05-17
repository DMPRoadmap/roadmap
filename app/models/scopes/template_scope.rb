require 'active_support/concern'

module TemplateScope
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where(archived: true) }
    scope :unarchived, -> { where(archived: false) }
#    scope :default, -> { published(where(is_default: true).last) }
    scope :default, -> { where(is_default: true, published: true).last }
    scope :published, -> (family_id = nil) { 
      if family_id.present?
        unarchived.where(published: true, family_id: family_id)
      else
        unarchived.where(published: true) 
      end
    }
    
    # Retrieves the latest templates, i.e. those with maximum version associated. It can be filtered down
    # if family_id is passed. NOTE, the template objects instantiated only contain version and family attributes
    # populated. See Template::latest_version scope method for an adequate instantiation of template instances
    scope :latest_version_per_family, -> (family_id = nil) {
      chained_scope = unarchived.select("MAX(version) AS version", :family_id)
      if family_id.present?
        chained_scope = chained_scope.where(family_id: family_id)
      end
      chained_scope.group(:family_id)
    }
    scope :latest_customized_version_per_customised_of, -> (customization_of=nil, org_id = nil) {
      chained_scope = select("MAX(version) AS version", :customization_of)
      chained_scope = chained_scope.where(customization_of: customization_of)
      if org_id.present?
        chained_scope = chained_scope.where(org_id: org_id)
      end
      chained_scope.group(:customization_of)
    }
    # Retrieves the latest templates, i.e. those with maximum version associated. It can be filtered down
    # if family_id is passed
    scope :latest_version, -> (family_id = nil) {
      unarchived.from(latest_version_per_family(family_id), :current)
        .joins("INNER JOIN templates ON current.version = templates.version " +
             "AND current.family_id = templates.family_id INNER JOIN orgs ON orgs.id = templates.org_id")
    }
    # Retrieves the latest customized versions, i.e. those with maximum version associated for a set
    # of family_id and an org
    scope :latest_customized_version, -> (family_id = nil, org_id = nil) {
      unarchived.from(latest_customized_version_per_customised_of(family_id, org_id), :current)
      .joins("INNER JOIN templates ON current.version = templates.version"\
        " AND current.customization_of = templates.customization_of INNER JOIN orgs ON orgs.id = templates.org_id")
      .where(templates: { org_id: org_id })
    }
    # Retrieves the latest templates, i.e. those with maximum version associated for a set of org_id passed
    scope :latest_version_per_org, -> (org_id = nil) {
      if org_id.respond_to?(:each)
        family_ids = families(org_id).pluck(:family_id)
      else
        family_ids = families([org_id]).pluck(:family_id)
      end
      latest_version(family_ids)
    }
    # Retrieve all of the latest customizations for the specified org
    scope :latest_customized_version_per_org, -> (org_id=nil) {
      family_ids = families(org_id).pluck(:family_id)
      latest_customized_version(family_ids, org_id)
    }
    # Retrieves templates with distinct family_id. It can be filtered down if org_id is passed
    scope :families, -> (org_id=nil) {
      if org_id.respond_to?(:each)
        unarchived.where(org_id: org_id, customization_of: nil).distinct
      else
        unarchived.where(customization_of: nil).distinct
      end 
    }
    # Retrieves the latest version of each customizable funder template (and the default template)
    scope :latest_customizable, -> {
      family_ids = families(Org.funder.collect(&:id)).distinct.pluck(:family_id) << default.family_id
      published(family_ids.flatten).where('visibility = ? OR is_default = ?', visibilities[:publicly_visible], true)
    }    
    # Retrieves unarchived templates with public visibility
    scope :publicly_visible, -> { unarchived.where(:visibility => visibilities[:publicly_visible]) }
    # Retrieves unarchived templates with organisational visibility
    scope :organisationally_visible, -> { unarchived.where(:visibility => visibilities[:organisationally_visible]) }
    # Retrieves unarchived templates whose title or org.name includes the term passed
    scope :search, -> (term) {
      search_pattern = "%#{term}%"
      unarchived.where("templates.title LIKE ? OR orgs.name LIKE ?", search_pattern, search_pattern)
    }
  end
end

