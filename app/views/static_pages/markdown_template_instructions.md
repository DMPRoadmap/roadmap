DMPTool Markdown page instructions
===============

Use standard Markdown formatting on your file. There are numerous guides to Markdown syntax online, for example: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet

**Making text available for translation**
If you would like to allow the text on the page to be available for localized translations, wrap the text in Rails/GetText style markup:
```ruby
## Untranslatable heading

Untranslatable regular text **Bold - Untranslatable Markdown Text**

-------------------------

## <%= _('Translatable heading') %>

<%= _('Translatable regular text') %> **<%= _('Bold - Translatable Markdown Text') %>**
```

Just place `<%= _('` at the beginning of the text and `') %>` at the end of the text. 

Do not include Markdown in the translatable text. The system Mardown converter will skip any text included in `<%= _('') %>` code blocks.
For example: `<%= _('Translatable regular text **Bold - Translatable Markdown Text**') %>` would result in `<p>Translatable regular text **Bold - Translatable Markdown Text**<p>`)

**Do NOT use the following!**
Avoid the use of `~|1|~`, `~|27|~`, `~|534|~`, `~|2.7|~`, etc. This will cause problems with the conversion of the document to HTML
