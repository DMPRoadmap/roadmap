module Dmpopidor
    module Controllers
      module PublicPages
        # GET template_index
        # -----------------------------------------------------
        # Every publised template is displayed in the Templates Public pages
        # the templates are sorted by org name
        def template_index
          templates = Template.live(Template.families(Org.all.pluck(:id)).pluck(:family_id)).pluck(:id) <<
                Template.where(is_default: true).unarchived.published.pluck(:id)
          @templates = Template.includes(:org)
                         .where(id: templates.uniq.flatten)
                         .unarchived.published.order("orgs.name asc").page(1)
        end
      end
    end
  end