require_relative 'target'
require 'csv'
require 'concurrent'
require_relative 'options'

module SITEFIND
  class Finder

    def initialize(target)
      @options = Parser.parse target
    end

    def run
      tgts = []

      if @options["file"]
        CSV.readlines(@options["file"]).each do |t|
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

      puts "Writing results to file"
      
      tgts.each do |t|
        if t.http_success or t.https_success
          puts "Looking at: #{t.start_address}"
          puts "Site on port 80: #{t.http_success}"
          puts "Site on port 443: #{t.https_success}"
          puts ""
        end
      end

    end

  end

end

# finder = SITEFIND::Finder.new(%W(-f c:/users/ryne/desktop/cmsscan.csv))
# puts finder.inspect
# finder = SITEFIND::Finder.new(%W(-t google.com))

# finder = SITEFIND::Finder.new(ARGV)
# finder.run
