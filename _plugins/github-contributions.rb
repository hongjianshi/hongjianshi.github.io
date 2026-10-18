# Fetch the public GitHub contribution calendar at build time and render it for
# the repositories page, so the site shows the same numbers as the GitHub profile
# (including anonymized private contributions, if enabled in GitHub settings).
# If GitHub cannot be reached, the build continues without the calendar.
require "cgi"
require "date"
require "net/http"
require "uri"

module Jekyll
  class GithubContributions < Generator
    safe true
    priority :high

    URL = "https://github.com/users/%s/contributions".freeze
    WEEKDAYS = { 1 => "Mon", 3 => "Wed", 5 => "Fri" }.freeze

    def generate(site)
      username = site.config["github_username"]
      return if username.to_s.empty?

      calendar = self.class.parse(self.class.fetch(format(URL, username)))
      calendar["html"] = self.class.render(calendar, username)
      site.data["github_contributions"] = calendar
    rescue StandardError => e
      Jekyll.logger.warn "GitHub contributions:", "skipped (#{e.class}: #{e.message})"
    end

    def self.fetch(url)
      uri = URI(url)
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.get(uri.request_uri, "User-Agent" => "Mozilla/5.0 (Jekyll build)")
      end
      raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body.force_encoding("UTF-8")
    end

    def self.parse(html)
      total = html[/([\d,]+)\s+contributions?\s+in the last year/, 1] or raise "total not found"

      labels = {}
      html.scan(%r{<tool-tip[^>]*\bfor="contribution-day-component-(\d+)-(\d+)"[^>]*>([^<]*)</tool-tip>}) do |row, col, text|
        labels[[row.to_i, col.to_i]] = CGI.unescapeHTML(text.strip)
      end

      days = html.scan(/<td\b[^>]*\bdata-date="[^"]*"[^>]*>/).map do |tag|
        pos = tag.match(/\bid="contribution-day-component-(\d+)-(\d+)"/) or next
        row, col = pos[1].to_i, pos[2].to_i
        {
          "date"  => tag[/\bdata-date="([^"]+)"/, 1],
          "row"   => row,
          "col"   => col,
          "level" => tag[/\bdata-level="(\d)"/, 1].to_i,
          "label" => labels[[row, col]].to_s,
        }
      end.compact
      raise "no days found" if days.empty?

      { "total" => total, "days" => days }
    end

    def self.render(calendar, username)
      days = calendar["days"]
      weeks = days.map { |d| d["col"] }.max + 1
      week_start = days.group_by { |d| d["col"] }.transform_values { |ds| Date.parse(ds.min_by { |d| d["row"] }["date"]) }

      # Label a week when it starts a new month; drop the first label if it has no room.
      months = (0...weeks).select { |col| col.zero? || week_start[col].month != week_start[col - 1].month }
      months.shift if months.size > 1 && months[1] - months[0] < 3

      cells = months.map do |col|
        %(<span class="contrib-month" style="grid-area: 1 / #{col + 2}">#{week_start[col].strftime("%b")}</span>)
      end
      cells += WEEKDAYS.map do |row, name|
        %(<span class="contrib-weekday" style="grid-area: #{row + 2} / 1">#{name}</span>)
      end
      cells += days.map do |d|
        %(<span class="contrib-day" data-level="#{d["level"]}" title="#{CGI.escapeHTML(d["label"])}" style="grid-area: #{d["row"] + 2} / #{d["col"] + 2}"></span>)
      end

      legend = (0..4).map { |level| %(<span class="contrib-day" data-level="#{level}"></span>) }.join
      noun = calendar["total"] == "1" ? "contribution" : "contributions"

      # One line, so Markdown pages do not treat indented lines as code blocks.
      [
        %(<div class="contrib">),
        %(<p class="contrib-total"><a href="https://github.com/#{username}">#{calendar["total"]} #{noun}</a> in the last year</p>),
        %(<div class="contrib-scroll"><div class="contrib-graph" style="grid-template-columns: auto repeat(#{weeks}, minmax(0, 1fr))">#{cells.join}</div></div>),
        %(<div class="contrib-legend">Less #{legend} More</div>),
        %(</div>),
      ].join
    end
  end
end
