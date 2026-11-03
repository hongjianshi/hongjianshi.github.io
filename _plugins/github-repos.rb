# Fetch the metadata of the repositories listed in _data/repositories.yml from
# the GitHub API at build time and render a card for each, so the repositories
# page does not depend on the github-readme-stats service, whose public
# deployment can be paused and then leaves a broken image. A GITHUB_TOKEN in the
# environment raises the API rate limit; without one the public limit is used.
# If a repository cannot be fetched, a plain card with its name is rendered.
require "cgi"
require "json"
require "net/http"
require "uri"

module Jekyll
  class GithubRepos < Generator
    safe true
    priority :high

    API = "https://api.github.com/repos/%s".freeze
    FIELDS = %w[description language stargazers_count forks_count html_url].freeze

    # Linguist colours of the languages likely to appear; any other gets a grey dot.
    LANGUAGE_COLORS = {
      "R" => "#198CE7", "Python" => "#3572A5", "Jupyter Notebook" => "#DA5B0B",
      "TeX" => "#3D6117", "MATLAB" => "#e16737", "C++" => "#f34b7d", "C" => "#555555",
      "Julia" => "#a270ba", "Shell" => "#89e051", "HTML" => "#e34c26",
      "JavaScript" => "#f1e05a", "TypeScript" => "#3178c6", "Java" => "#b07219",
      "Rust" => "#dea584", "Go" => "#00ADD8", "Ruby" => "#701516", "Fortran" => "#4d41b1",
      "Stan" => "#b2011d", "Makefile" => "#427819", "CSS" => "#663399", "SCSS" => "#c6538c",
      "Mathematica" => "#dd1100",
    }.freeze

    def generate(site)
      repos = Array(site.data.dig("repositories", "github_repos")).map(&:to_s)
      return if repos.empty?

      owners = Array(site.data.dig("repositories", "github_users")).map(&:to_s)
      site.data["github_repos"] = repos.each_with_object({}) do |full_name, cards|
        info = begin
          self.class.fetch(format(API, full_name)).slice(*FIELDS)
        rescue StandardError => e
          Jekyll.logger.warn "GitHub repositories:", "#{full_name}: #{e.class}: #{e.message}; rendering a plain card"
          {}
        end
        show_owner = !owners.include?(full_name.split("/").first)
        cards[full_name] = info.merge("html" => self.class.render(full_name, info, show_owner))
      end
    end

    def self.fetch(url)
      uri = URI(url)
      headers = { "User-Agent" => "Jekyll build", "Accept" => "application/vnd.github+json" }
      token = ENV["GITHUB_TOKEN"].to_s
      headers["Authorization"] = "Bearer #{token}" unless token.empty?
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
        http.get(uri.request_uri, headers)
      end
      raise "HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def self.render(full_name, info, show_owner)
      url = info["html_url"] || "https://github.com/#{full_name}"
      title = show_owner ? full_name : full_name.split("/", 2).last
      parts = [
        %(<a class="repo-card" href="#{CGI.escapeHTML(url)}">),
        %(<span class="repo-card-title"><i class="fab fa-github"></i>#{CGI.escapeHTML(title)}</span>),
      ]
      description = info["description"].to_s.strip
      parts << %(<span class="repo-card-description">#{CGI.escapeHTML(description)}</span>) unless description.empty?
      unless info.empty?
        meta = []
        language = info["language"].to_s
        unless language.empty?
          color = LANGUAGE_COLORS.fetch(language, "#8b949e")
          meta << %(<span class="repo-card-language"><span class="repo-card-dot" style="background-color: #{color}"></span>#{CGI.escapeHTML(language)}</span>)
        end
        meta << %(<span class="repo-card-stat" title="stars"><i class="fas fa-star"></i>#{info["stargazers_count"].to_i}</span>)
        meta << %(<span class="repo-card-stat" title="forks"><i class="fas fa-code-branch"></i>#{info["forks_count"].to_i}</span>)
        parts << %(<span class="repo-card-meta">#{meta.join}</span>)
      end
      parts << %(</a>)
      # One line, so Markdown pages do not treat indented lines as code blocks.
      parts.join
    end
  end
end
