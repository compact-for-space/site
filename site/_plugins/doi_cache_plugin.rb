# frozen_string_literal: true

puts 'DOI Plugin is loading...'

# frozen_string_literal: true
require 'net/http'
require 'json'
require 'uri'
require 'yaml'
require 'openssl'

# DOI Cache Plugin
#
# This plugin generates a cache of publication metadata (title, authors, date)
# by fetching data from Crossref via DOI. It processes `publications.yaml`
# and updates `doi_cache.yaml` automatically.
class DoiCachePlugin < Jekyll::Generator
  def initialize(options = {})
    super
    @pubs_path = nil
    @cache_path = nil
  end

  def generate(site)
    @pubs_path = File.join(site.source, '_data', 'publications.yaml')
    @cache_path = File.join(site.source, '_data', 'doi_cache.yaml')

    return unless File.exist?(@pubs_path)

    publications = load_publications
    cache = load_cache

    need_save = false

    publications.each do |pub|
      doi = pub['doi'].to_s
      next if doi.empty?
      next if pub_complete?(pub) || cache.key?(doi)

      puts "-----------------> Fetching DOI (Missing Data): #{doi}..."
      raw_metadata = fetch_with_redirects(doi)

      if valid_metadata?(raw_metadata)
        cache[doi] = filter_metadata(raw_metadata)
        need_save = true
        puts "Added minimized data for #{doi} to cache."
      else
        puts "ERROR: Could not fetch valid metadata for DOI #{doi}."
      end
    end

    if need_save
      puts "Saving minimized cache to #{@cache_path}..."
      save_cache(cache)
    end

    site.data['doi_cache'] = cache
  end

  private

  # --- Datei- und Daten-Handling ---

  def load_publications
    YAML.load_file(@pubs_path) || []
  end

  def load_cache
    File.exist?(@cache_path) ? (YAML.load_file(@cache_path) || {}) : {}
  end

  def save_cache(cache)
    File.write(@cache_path, cache.to_yaml)
  end

  # --- Logik-Prüfungen ---

  def pub_complete?(pub)
    pub.key?('title') && pub.key?('authors') && pub.key?('date')
  end

  def valid_metadata?(meta)
    return false unless meta

    has_title = meta['title'].is_a?(Array) ? !meta['title'].empty? : !meta['title'].nil?
    has_authors = meta['author'].is_a?(Array) && !meta['author'].empty?
    has_date = meta['issued'] || meta['created'] || meta['published-print']
    has_title && has_authors && has_date
  end

  # --- Metadaten-Verarbeitung ---

  def filter_metadata(meta)
    {
      'title' => meta['title'],
      'author' => meta['author'],
      'date' => extract_best_date(meta)
    }
  end

  def extract_best_date(meta)
    date_source = meta['issued'] || meta['created'] || meta['published-print']
    return '0000-01-01' unless date_source

    if date_source.is_a?(Hash) && date_source.key?('date-parts')
      parts = date_source['date-parts'][0]
      formatted = format_date_parts(parts)
      return formatted || '0000-01-01'
    elsif date_source.is_a?(String)
      return format_date_string(date_source)
    end
    '0000-01-01'
  end

  def format_date_parts(parts)
    return nil unless parts

    if parts[0] && parts[1] && parts[2]
      "#{parts[0]}-#{parts[1].to_s.rjust(2, '0')}-#{parts[2].to_s.rjust(2, '0')}"
    elsif parts[0]
      "#{parts[0]}-01-01"
    end
  end

  def format_date_string(date_str)
    return '0000-01-01' if date_str.length == 4

    date_str
  end

  # --- HTTP & API ---

  def fetch_with_redirects(doi, limit = 5)
    raise 'Too many redirects' if limit.zero?

    uri = URI.parse("https://doi.org/#{doi}")
    request = create_request(uri)

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    response = http.request(request)
    handle_response(response, limit)
  end

  def create_request(uri)
    req = Net::HTTP::Get.new(uri)
    req['Accept'] = 'application/vnd.citationstyles.csl+json;q=1.0, application/json'
    req['User-Agent'] = 'JekyllDoiPlugin/1.0'
    req
  end

  def handle_response(response, limit)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    when Net::HTTPRedirection
      fetch_with_redirects(response['location'], limit - 1)
    end
  end
end

puts 'DOI Plugin loaded'
