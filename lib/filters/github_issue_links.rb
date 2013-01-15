module Nanoc3::Filters

  class GithubIssueLinks < Nanoc3::Filter

    identifiers :github_issue_links

    def run(content, opts={})
      project  = opts[:project] || 'bobthecow/genghis'
      base_url = "https://github.com/#{project}/issues/"
      content.gsub(/\b(?:(?:Fix|See) )?#(\d+)\b/, "<a href=\"#{base_url}\\1\">\\0</a>")
    end

  end
end