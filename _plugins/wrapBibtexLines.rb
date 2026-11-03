# Wrap long field lines of the BibTeX shown behind the "Bib" button so the
# block does not need a horizontal scrollbar. A field line longer than
# site.bibtex_wrap_width characters is broken at spaces inside its value, and
# every continuation line is indented to the column where the text inside the
# value's braces (or quotes) starts, in the style of MathSciNet exports. Lines that are not field lines (the
# entry header and the closing brace) are left alone, and a single word
# longer than the available room stays on one line. Display only: the files
# in _bibliography/ are not touched. Set bibtex_wrap_width to 0 to disable.
module Jekyll
  module WrapBibtexLines
    def wrapBibtexLines(input)
      width = (@context.registers[:site].config['bibtex_wrap_width'] || 0).to_i
      return input if width <= 0
      lines = input.each_line.map { |line| wrap_bibtex_line(line.chomp, width) }
      lines.join("\n") + (input.end_with?("\n") ? "\n" : "")
    end

    private

    def wrap_bibtex_line(line, width)
      return line if line.length <= width
      m = line.match(/\A([ \t]*[A-Za-z_][A-Za-z0-9_\-]*[ \t]*=[ \t]*)(.*)\z/)
      return line unless m
      head, value = m[1], m[2]
      # hang under the first character inside the opening brace or quote
      indent = ' ' * (head.length + (value.start_with?('{', '"') ? 1 : 0))
      out = []
      current = head
      first_on_line = true
      value.split(' ').each do |word|
        if first_on_line
          current += word
          first_on_line = false
        elsif current.length + 1 + word.length <= width
          current += ' ' + word
        else
          out << current
          current = indent + word
        end
      end
      out << current
      out.join("\n")
    end
  end
end

Liquid::Template.register_filter(Jekyll::WrapBibtexLines)
