# SPDX-FileCopyrightText: 2026 Daniel Mohr
#
# SPDX-License-Identifier: CC-BY-SA-4.0

# frozen_string_literal: true

puts 'env plugin is loading...'

# Jekyll plugin that exposes environment variables to Liquid templates
# via `site.env.*`. Example:
#
#   {{ site.env.BUILD_TIME }}
#   {{ site.env.CI_COMMIT_SHA }}
#
# Security & Design Principles:
#   * Avoid accidental leakage of secrets, internal paths, or build tools.
#   * Use pattern-based filtering to cover common sensitive prefixes.
#   * Keep state minimal: variables are loaded once at startup (no runtime overhead).
#
# Example using in Liquid:
#
# DOI: {{ site.config.env.DOI }}
class EnvVars < Jekyll::Generator
  safe true
  priority :low
  # List of regex patterns to exclude from `site.env`.
  # Each pattern matches variable names that should *not* be exposed:
  #
  #   *PASSWORD* --> Generic password patterns (e.g., DB_PASSWORD, JWT_SECRET)
  #   *TOKEN*    --> API tokens, auth tokens (e.g., GITHUB_TOKEN, API_TOKEN)
  #   *API_KEY*  --> API credentials (e.g., STRIPE_API_KEY, SENDGRID_API_KEY)
  #   *SECRET*   --> Generic secrets (e.g., SECRET_KEY_BASE, ENCRYPTION_SECRET)
  #   SSH_*      --> SSH keys/paths (e.g., SSH_AUTH_SOCK, SSH_ASKPASS)
  #
  #   This list is *defensive*, not exhaustive.
  #
  SENSITIVE_PATTERNS = [
    /PASSWORD/i,
    /TOKEN/i,
    /API_KEY/i,
    /SECRET/i,
    /_SECRET$/,
    /^SSH_/i
  ].freeze
  def generate(site)
    env_vars = {}
    ENV.each do |key, value|
      next if key.nil? || value.nil?
      # Skip sensitive patterns
      next if SENSITIVE_PATTERNS.any? { |pat| pat.match?(key) }

      env_vars[key] = value
    end
    site.config['env'] = env_vars.freeze
    puts "[env] loaded #{env_vars.size} vars (JEKYLL_ENV=#{env_vars['JEKYLL_ENV']})" if ENV['JEKYLL_DEBUG'] == 'true'
  end
end

puts 'env plugin loaded'
