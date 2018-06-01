require './sitefind/target'
require './sitefind/options'
require './sitefind/finder'

module SITEFIND
  class << self
    VERSION = "0.0.1"

    def run(options)
      SITEFIND::Finder.new(options).run
    end

  end
end

SITEFIND.run(ARGV)