# frozen_string_literal: true

# Helper methods for stubbing Rails configuration settings
module ConfigHelper

  # This service expects an OpenStruct class, not a Hash!!
  #   instead of { foo: 'bar' } send OpenStruct.new(foo: 'bar')
  #
  # This will allow Rails.configuration.x.[section_sym].foo to return 'bar'
  def stub_x_section(section_sym:, open_struct: {})
    Rails.configuration.x.stubs(section_sym).returns(open_struct)
  end

end
