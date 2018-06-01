require 'optparse'
require 'colorize'

Options = Struct.new(:target, :file, :output)

class Parser
  def self.parse(options)
    args = Options.new()

    opt_parser = OptionParser.new do |opts|
      opts.banner = "
      _/_/_/  _/    _/                    _/_/_/_/  _/                  _/                      
   _/            _/_/_/_/    _/_/        _/            _/_/_/      _/_/_/    _/_/    _/  _/_/   
    _/_/    _/    _/      _/_/_/_/      _/_/_/    _/  _/    _/  _/    _/  _/_/_/_/  _/_/        
       _/  _/    _/      _/            _/        _/  _/    _/  _/    _/  _/        _/           
_/_/_/    _/      _/_/    _/_/_/      _/        _/  _/    _/    _/_/_/    _/_/_/  _/".red + "     

      Usage: site_find.rb [options]"

      opts.on("-tTARGET", "--target=TARGET", "Target to find") do |n|
        args.target = n
      end

      opts.on("-fFILE", "--file=FILE", "File with targets to find") do |n|
        args.file = n
      end

      opts.on("-oOUTPUT", "--output=OUTPUT", "File for writing results") do |n|
        args.output = n
      end

      opts.on("-h", "--help", "Prints this help") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(options)
    return args
  end
end
# options = Parser.parse(%W[-f file])
# puts options