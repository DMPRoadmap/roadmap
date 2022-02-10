# frozen_string_literal: true

module Dmpopidor

  module Theme

    def to_slug
      title.parameterize.truncate(80, omission: "")
    end

    # ADDITION: generate slug from title
    def generate_slug
      self.slug = title.parameterize if title
    end

  end

end
