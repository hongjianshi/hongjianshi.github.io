# Give every line of the highlighted BibTeX behind the "Bib" button a hanging
# indent. Rouge returns the block as one <pre><code> element, in which a
# line that is too wide for the box (a long URL, or any line on a narrow
# screen) wraps back to the left margin. This filter wraps each line in a
# block-level <span class="bibline">, and the stylesheet gives that span a
# padding-left equal to the value column and the same negative text-indent,
# so wrapped rows continue under the value. Highlight spans that Rouge left
# open across a line break are closed at the end of the line and reopened on
# the next one, so the markup stays well formed. Display only.
module Jekyll
  module HangingBibtexLines
    SPAN_TAG = %r{<span\b[^>]*>|</span>}.freeze

    def hangingBibtexLines(input)
      input.sub(%r{(<code\b[^>]*>)(.*?)(</code>)}m) do
        Regexp.last_match(1) + wrap_lines_in_spans(Regexp.last_match(2)) + Regexp.last_match(3)
      end
    end

    private

    def wrap_lines_in_spans(body)
      lines = body.split("\n", -1)
      lines.pop while lines.length > 1 && lines.last.strip.empty?
      open_spans = []
      lines.map do |line|
        prefix = open_spans.join
        line.scan(SPAN_TAG) { |tag| tag == '</span>' ? open_spans.pop : open_spans.push(tag) }
        suffix = '</span>' * open_spans.length
        %(<span class="bibline">#{prefix}#{line}#{suffix}</span>)
      end.join
    end
  end
end

Liquid::Template.register_filter(Jekyll::HangingBibtexLines)
