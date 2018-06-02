require_relative 'target'
require_relative 'options'
require 'csv'
require 'yaml'
require 'oj'
require 'concurrent'

module SITEFIND
  class Finder

    def initialize(target)
      @options = Parser.parse target
    end

    def run
      tgts = []

      if @options["tgt_file"]
        CSV.readlines(@options["tgt_file"]).each do |t|
          tgts << SITEFIND::Target.new(t[0])
        end
      end

      if @options["target"]
        tgts << SITEFIND::Target.new(@options["target"])
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
      begin
        while pool.length > 0 && pool.queue_length > 0
          puts "wating"
          puts pool.queue_length
          puts pool.length
          sleep 5
        end
      rescue Interrupt
        puts "Killing Finder threads."
        pool.kill
      end

      pool.shutdown
      pool.wait_for_termination(60)

      if @options["json_output"]
        puts "Writing to json file: #{@options["output_file"]}.json"
        File.open("#{@options["output_file"]}.json", "w") do |f|
          tgts.each do |t|
            f.puts Oj::dump t, indent: 2
          end
        end
      end

      if @options["yaml_output"]
        puts "Writing to yaml file: #{@options["output_file"]}.yaml"
        File.open("#{@options["output_file"]}.yaml", "w") do |f|
          tgts.each do |t|
            f.puts t.to_yaml
          end
        end
      end

      if @options["csv_output"]
        puts "Writing to csv file: #{@options["output_file"]}.csv"
        File.open("#{@options["output_file"]}.csv", "w") do |csv|
          headers = %w(target ip site status upgrade http https)
          csv << headers.join(",")
          csv << "\n"
          tgts.each do |t|
            val_arr = [t.start_address,t.ip_address,t.end_address,t.code_trail[-1],t.ssl_upgrade,t.http_success,t.https_success]
            csv << val_arr.join(",")
            csv << "\n"
          end
        end
      end

=begin
      tgts.each do |t|
        if t.http_success or t.https_success
          puts "Looking at: #{t.start_address}"
          puts "Site on port 80: #{t.http_success}"
          puts "Site on port 443: #{t.https_success}"
          puts ""
        end
      end
=end

    end

  end

end

# finder = SITEFIND::Finder.new(%W(-f c:/users/ryne/desktop/cmsscan.csv))
# puts finder.inspect
# finder = SITEFIND::Finder.new(%W(-t google.com))

# finder = SITEFIND::Finder.new(ARGV)
# finder.run
