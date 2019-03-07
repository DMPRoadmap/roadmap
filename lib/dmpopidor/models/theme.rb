module Dmpopidor
  module Model
    module Theme
      ##
      # Before save & create, generate the slup
      before_save :generate_slug

      def to_slug
        title.parameterize.truncate(80, omission: '')
      end
    
      def generate_slug
        if self.title
          self.slug = self.title.parameterize
        end
      end
    end
  end
end
  