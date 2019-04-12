module Dmpopidor
    module Controllers
      module Application
        # Set Static Pages collection to use in navigation
        def set_nav_static_pages
            @nav_static_pages = StaticPage.navigable
        end
      end
    end
  end