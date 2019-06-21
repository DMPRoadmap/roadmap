module Dmpopidor
    module Controllers
      module Paginable
        module Templates
  
          # GET /paginable/templates/publicly_visible/:page  (AJAX)
          # -----------------------------------------------------
          # In the public page, every published templates is displayed.
          def publicly_visible
            templates = Template.live(Template.families(Org.all.pluck(:id)).pluck(:family_id)).pluck(:id) <<
              Template.where(is_default: true).unarchived.published.pluck(:id)
            paginable_renderise(
              partial: "publicly_visible",
              scope: Template.joins(:org)
                            .includes(:org)
                            .where(id: templates.uniq.flatten)
                            .published,
              query_params: { sort_field: 'templates.title', sort_direction: :asc }
            )
          end
        end
      end
    end
  end