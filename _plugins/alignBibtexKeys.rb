# Pad the field keys of the BibTeX shown behind the "Bib" button so that the
# equals signs line up, matching the layout of the files in _bibliography/.
# jekyll-scholar builds that string with BibTeX::Entry#to_s, which always
# writes "key = value" with single spaces, so the alignment is restored here.
# The key column width is site.bibtex_key_width (default 10); keys longer than
# that are left at their natural length.
module Jekyll
  module AlignBibtexKeys
    def alignBibtexKeys(input)
      width = (@context.registers[:site].config['bibtex_key_width'] || 10).to_i
      input.gsub(/^[ \t]*([A-Za-z_][A-Za-z0-9_\-]*)[ \t]*=[ \t]*/) do
        "  #{Regexp.last_match(1).downcase.ljust(width)} = "
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::AlignBibtexKeys)
