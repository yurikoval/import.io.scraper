$LOAD_PATH.unshift '.'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'byebug'
require 'csv'

class Importer
  def self.scrape(args)
    instance = new args
    instance.scrape
  end

  def initialize(args)
    @config = args.delete(:config)
    @url_set = args.delete(:url_set)
    @write_to = args.delete(:write_to)
  end

  def scrape
    @url_set.each do |url|
      data = extract_data(url)
      write_to_file(data)
    end
  end
  private
    def extract_data(url)
      puts "Fetching #{url}"
      doc = Nokogiri::HTML(open(url))
      subjects.map do |subject|
        doc.xpath(subject[:xpath]).map do |link|
          returning = [link.content]
          returning << link.attributes['href'].value if subject[:type] == 'URL'
          returning
        end
      end.transpose.map(&:flatten)
    rescue
      puts "Failed to import #{url}"
      []
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
      CSV.open(@write_to, "w") do |csv|
        data.each{ |row| csv << row }
      end
    end
end
