MarkdownRails.configure do |config|
  renderer = Redcarpet::Render::HTML.new(:prettify => true)
  markdown = Redcarpet::Markdown.new(renderer,
                                     :fenced_code_blocks => true,
                                     :autolink => true)
  config.render do |markdown_source|
    markdown.render(markdown_source)
  end
end