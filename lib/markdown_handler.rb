module MarkdownHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end
  
  def self.call(template)
    # Copy the options of the template so we can send them to the ERB compiler
    details = {
      locals: template.locals,
      virtual_path: template.virtual_path,
      updated_at: template.updated_at
    }
    renderer = Redcarpet::Render::HTML.new({})
    markdown ||= Redcarpet::Markdown.new(renderer, {})

    # Extract any codeblocks from the markdown so that we can pass them on to the ERB template handler
    sanitized_source = template.source
    code_blocks = []
    template.source.scan(/<%.+?%>/) do |block|
      code_blocks << block
      sanitized_source = sanitized_source.sub(block.to_s, "~|#{code_blocks.length - 1}|~")
    end
    
    # Now passed the HTML version of the markdown through the regular ERB handler so any inline code is processed normally
    converted_source = markdown.render(sanitized_source)

    # Add any codeblocks back into the converted HTML
    reconstituted_source = converted_source
    reconstituted_source.scan(/~\|[\d]+\|~/) do |block|
      i = block.gsub('~|', '').gsub('|~', '').to_i
      reconstituted_source = reconstituted_source.sub(block, code_blocks[i])
    end

    new_template = ActionView::Template.new(reconstituted_source, template.identifier, template.handler, details)
    ActionView::Template::Handlers::ERB.call(new_template)
  end
end

ActionView::Template.register_template_handler :md, MarkdownHandler