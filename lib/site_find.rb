require_relative 'sitefind/target'
require_relative 'sitefind/options'
require_relative 'sitefind/finder'

module SITEFIND
  class << self
    VERSION = "0.0.1"

    def run(options)
      SITEFIND::Finder.new(options).run
    end

  end
end

SITEFIND.run(ARGV)
print "\a"
