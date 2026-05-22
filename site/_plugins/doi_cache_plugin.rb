# frozen_string_literal: true

puts 'DOI Plugin is loading...'

require 'net/http'
require 'json'
require 'uri'
require 'yaml'
require 'openssl'

# DOI Cache Plugin
#
# This plugin generates a cache of publication metadata (title, authors, date)
# by fetching data from doi.org. It processes `publications.yaml`
# and updates `doi_cache.yaml` automatically.
class DoiCachePlugin < Jekyll::Generator
  def generate(site)
    pubs_path = File.join(site.source, '_data', 'publications.yaml')
    cache_path = File.join(site.source, '_data', 'doi_cache.yaml')
    return unless File.exist?(pubs_path)

    publications = YAML.load_file(pubs_path) || []
    cache = File.exist?(cache_path) ? (YAML.load_file(cache_path) || {}) : {}
    updated_cache = false

    publications.each do |pub|
      doi = pub['doi'].to_s
      next if doi.empty?

      # STEP 1: Check if the entry is fully complete.
      # Now using 'date' instead of 'year'.
      has_core_data = pub['title'] && pub['authors'] && pub['date']
      has_link = pub['doi'] || pub['url']
      is_complete = has_core_data && has_link

      next if is_complete

      # STEP 2: Check if data already exists in the cache file.
      next if cache.key?(doi)

      # STEP 3: Perform API request if data is missing.
      puts "-----------------> Fetching DOI (Missing Data): #{doi}..."
      raw_metadata = fetch_with_redirects(doi)

      if raw_metadata && valid_metadata?(raw_metadata)
        cache[doi] = filter_metadata(raw_metadata)
        updated_cache = true
        puts "Added minimized data for #{doi} to cache."
      else
        puts "ERROR: Could not fetch valid metadata for DOI #{doi}."
      end
    end

    if updated_cache
      puts "Saving minimized cache to #{cache_path}..."
      File.write(cache_path, cache.to_yaml)
    end
    site.data['doi_cache'] = cache
  end

  private

  # Extracts useful data and formats the date logically.
  def filter_metadata(meta)
    {
      'title' => meta['title'],
      'author' => meta['author'],
      'date' => extract_best_date(meta)
    }
  end

  # Tries to find the most precise date available in the JSON metadata.
  def extract_best_date(meta)
    date_source = meta['issued'] || meta['created'] || meta['published-print']
    return '0000-01-01' unless date_source

    if date_source.is_a?(Hash) && date_source['date-parts']
      parts = date_source['date-parts'][0]
      # Full date: YYYY-MM-DD
      if parts[0] && parts[1] && parts[2]
        return "#{parts[0]}-#{parts[1].to_s.rjust(2, '0')}-#{parts[2].to_s.rjust(2, '0')}"
      # Year only: YYYY-01-01 (for consistent sorting)
      elsif parts[0]
        return "#{parts[0]}-01-01"
      end
    elsif date_source.is_a?(String)
      # If it's just "2022", make it "2022-01-01"
      return date_source.length == 4 ? "#{date_source}-01-01" : date_source
    end
    '0000-01-01'
  end

  def fetch_with_redirects(doi, limit = 5)
    raise 'Too many redirects' if limit.zero?

    uri = URI.parse("https://doi.org/#{doi}")
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/vnd.citationstyles.csl+json;q=1.0, application/json'
    request['User-Agent'] = 'JekyllDoiPlugin/1.0'
    response = http.request(request)
    case response
    when Net::HTTPSuccess then JSON.parse(response.body)
    when Net::HTTPRedirection then fetch_url_with_redirects(response['location'], limit - 1)
    end
  end

  def fetch_url_with_redirects(url, limit = 5)
    raise 'Too many redirects' if limit.zero?

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    request = Net::HTTP::Get.new(uri)
    request['Accept'] = 'application/vnd.citationstyles.csl+json;q=1.0, application/json'
    request['User-Agent'] = 'JekyllDoiPlugin/1.0'
    response = http.request(request)
    case response
    when Net::HTTPSuccess then JSON.parse(response.body)
    when Net::HTTPRedirection then fetch_url_with_redirects(response['location'], limit - 1)
    end
  end

  def valid_metadata?(meta)
    has_title = (meta['title'].is_a?(Array) ? !meta['title'].empty? : !meta['title'].nil?)
    has_authors = meta['author'].is_a?(Array) && !meta['author'].empty?
    has_date = meta['issued'] || meta['created'] || meta['published-print']
    has_title && has_authors && has_date
  end
end

puts 'DOI Plugin loaded'
