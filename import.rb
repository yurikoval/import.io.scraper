$LOAD_PATH.unshift '.'
require 'importer'

file = File.read('configs/jp.suumo.json')
config = JSON.parse(file)

what_to_scrape = [
  {
    name: 'minato',
    url: "http://suumo.jp/jj/chintai/ichiran/FR301FC001/?ar=030&bs=040&ta=13&sc=13103&cb=0.0&ct=9999999&mb=0&mt=9999999&et=9999999&cn=9999999&shkr1=03&shkr2=03&shkr3=03&shkr4=03&sngz=&po1=00&po2=99&pc=50&pn=",
    pages: 336
  },
  {
    name: 'shibuya',
    url: "http://suumo.jp/jj/chintai/ichiran/FR301FC001/?ar=030&bs=040&ta=13&sc=13113&cb=0.0&ct=9999999&mb=0&mt=9999999&et=9999999&cn=9999999&shkr1=03&shkr2=03&shkr3=03&shkr4=03&sngz=&po1=00&po2=99&pc=100&pn=",
    pages: 146
  },
  {
    name: 'meguro',
    url: "http://suumo.jp/jj/chintai/ichiran/FR301FC001/?ar=030&bs=040&ta=13&sc=13110&cb=0.0&ct=9999999&mb=0&mt=9999999&et=9999999&cn=9999999&shkr1=03&shkr2=03&shkr3=03&shkr4=03&sngz=&po1=00&po2=99&pc=100&pn=",
    pages: 136
  },
  {
    name: 'setagaya',
    url: "http://suumo.jp/jj/chintai/ichiran/FR301FC001/?ar=030&bs=040&ta=13&sc=13112&cb=0.0&ct=9999999&mb=0&mt=9999999&et=9999999&cn=9999999&shkr1=03&shkr2=03&shkr3=03&shkr4=03&sngz=&po1=00&po2=99&pc=100&pn=",
    pages: 136
  },
  {
    name: 'shinagawa',
    url: "http://suumo.jp/jj/chintai/ichiran/FR301FC001/?ar=030&bs=040&ta=13&sc=13109&cb=0.0&ct=9999999&mb=0&mt=9999999&et=9999999&cn=9999999&shkr1=03&shkr2=03&shkr3=03&shkr4=03&sngz=&po1=00&po2=99&pc=100&pn=",
    pages: 168
  },
]

what_to_scrape.each do |subject|
  start_at = subject[:start_at] || 1
  url_set = ((start_at)...(subject[:pages])).map{ |num| "#{subject[:url]}#{num}" }
  date = Time.new().strftime('%Y-%m-%d')
  Importer.scrape config: config, url_set: url_set, write_to: "export_#{subject[:name]}_#{date}.csv"
end
