$LOAD_PATH.unshift '.'
require 'importer'

file = File.read('configs/jp.suumo.json')
config = JSON.parse(file)

url = "http://suumo.jp/jj/chintai/ichiran/FR301FC001/?ar=030&bs=040&ta=13&sc=13103&cb=0.0&ct=9999999&mb=0&mt=9999999&et=9999999&cn=9999999&shkr1=03&shkr2=03&shkr3=03&shkr4=03&sngz=&po1=00&po2=99&pc=50&pn="
url_set = (1..2).map{ |num| "#{url}#{num}" }

results = Importer.scrape config: config, url_set: url_set, write_to: 'export.txt'
