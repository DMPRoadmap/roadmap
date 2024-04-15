# frozen_string_literal: true

module ReactHelper
  def react(component_name, props: {}, **args)
    content_tag(:div, "", data: {react_component: component_name, props: props}, **args)
  end
end
