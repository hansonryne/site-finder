require_relative 'site_find'
require 'csv'
require 'concurrent'
require_relative 'sitefind/options'

options = Parser.parse(%W[-t google.com])
puts options

tgts = []

if options["file"]
  CSV.readlines(options["file"]).each do |t|
    tgts << SITEFIND::Target.new(t[0])
  end
end

if options["target"]
  tgts << SITEFIND::Target.new(options["target"])
end

pool = Concurrent::ThreadPoolExecutor.new(
  min_threads: 5,
  max_threads: 10,
  max_queue: 1000
) # 5 threads

tgts.each do |t|
  pool.post do
    t.find_site
  end
end
pool.shutdown
puts pool.wait_for_termination(60)

# puts tgts[0].start_address
# puts tgts[0].end_address
# puts tgts[0].ip_address

tgts.each do |t|
  puts t.start_address
  puts t.http_success
  puts t.https_success
  puts ""
end