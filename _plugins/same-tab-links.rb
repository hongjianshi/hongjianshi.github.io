# Undo jekyll-target-blank for links marked with the "same-tab" class
# (publication links in _layouts/bib.html), so they open in the current tab.
# Priority :low makes this hook run after jekyll-target-blank's.
Jekyll::Hooks.register [:pages, :documents], :post_render, priority: :low do |doc|
  next unless doc.output.is_a?(String) && doc.output.include?("same-tab")

  doc.output = doc.output.gsub(/<a\b[^>]*\bsame-tab\b[^>]*>/) do |tag|
    tag.sub(/\s+target="_blank"/, "").sub(/\s+rel="noopener noreferrer"/, "")
  end
end
