$LOAD_PATH.unshift '.'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'

class XPathScanError < Exception
end

class Importer
  def self.scrape(args)
    instance = new args
    instance.scrape
  end

  def initialize(args)
    @config = args.delete(:config)
    @url_set = args.delete(:url_set)
    @write_to = args.delete(:write_to)
    @failed_url_set = []
  end

  def scrape
    @url_set.each do |url|
      data = extract_data(url)
      write_to_file(data)
    end
    print_failed_scans if @failed_url_set.any?
  end
  private
    def extract_data(url)
      begin
        puts "Fetching #{url}"
        doc = Nokogiri::HTML(open(url))
        results = doc.xpath(@config['extraction']['resultXPaths'].first)
        raise XPathScanError, "No results in #{url}" if results.empty?
      rescue OpenURI::HTTPError, XPathScanError => e
        puts "Failed to fetch #{url}"
        puts e.message
        @failed_url_set << url
      end
      results.map.with_index(1) do |result, i|
        subjects.map do |subject|
          if match = result.xpath(subject[:xpath]).first
            returning = [match.content]
            if subject[:type] == 'URL'
              returning << match.attributes['href'].value rescue ''
            end
            returning
          else
            puts "No match found for `#{subject[:property]}` on item #{i} on #{url}"
            ['']
          end
        end.flatten
      end
    end

    def subjects
      @config['extraction']['resultPipeline'].map do |extract|
        {
          property: extract['configuration']['property'],
          xpath: extract['configuration']['xpaths'].first,
          regexp: extract['configuration']['regexp'],
          type: extract['configuration']['type'],
        }
      end
    end

    def write_to_file(data)
      CSV.open(@write_to, "a") do |csv|
        data.each{ |row| csv << row }
      end
    end

    def print_failed_scans
      puts "Failed to scan:"
      @failed_url_set.each do |url|
        puts "\t\t#{url}"
      end
    end
end
