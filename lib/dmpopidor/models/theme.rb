module Dmpopidor
  module Models
    module Theme

      
      def to_slug
        title.parameterize.truncate(80, omission: '')
      end
      # ADDITION: generate slug from title
      def generate_slug
        if self.title
          self.slug = self.title.parameterize
        end
      end
    end
  end
end
  