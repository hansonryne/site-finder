require_relative 'site_find'

tgts = File.open('c:\users\ryne\desktop\site-finder\text.txt').read
output = {}
threads = []

puts "Testing port 80 first..."

tgts.each_line do |line|
  threads << Thread.new do
    t = SITEFIND::Target.new("#{line.chomp}")
    http_result = t.find_http_site
    output[line.chomp.to_s] = http_result
  end
end

print 'Still scanning....'
iterator = 0
while threads.any?(&:alive?)
  if iterator == 20
    puts "Taking way too long for remaining sites to exist....RIP connections..."
    break
  end
  
  living = 0
  threads.each do |t|
    living += 1 unless t.alive?
  end
  puts "#{living} out of #{threads.length} sites scanned"
  sleep 3
  iterator += 1
end

threads.each do |t|
  if t.alive?
    t.kill
  end
end

threads.each(&:join)

puts "Trying port 443 for sites that errored out on port 80..."

threads2 =[]
output.each_pair do |k, v|
  if v.success == false && v.ip_address
    threads2 << Thread.new do
      https_result = v.find_https_site
      output[k] = https_result
    end
  end
end

print 'Still scanning....'
iterator = 0
while threads2.any?(&:alive?)
  if iterator == 20
    puts "Taking way too long again for remaining sites to exist....RIP connections..."
    break
  end
  
  living = 0
  threads2.each do |t|
    living += 1 unless t.alive?
  end
  puts "#{living} out of #{threads2.length} sites scanned"
  sleep 3
  iterator += 1
end

threads2.each do |t|
  if t.alive?
    t.kill
  end
end

threads2.each(&:join)

output.each_pair do |k, v|
  puts ""
  puts "#{k}  --->  #{v.success ? "Site Found: #{v.end_address}" : "Nothing there"}"
end