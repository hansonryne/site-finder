require 'optparse'
require 'colorize'

Options = Struct.new(:target, :output_file, :json_output, :yaml_output, :csv_output, :tgt_file)

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

      opts.on("-fTGT_FILE", "--file=TGT_FILE", "File with targets to find") do |n|
        args.tgt_file = n
      end

      opts.on("-oOUTFILE", "--outfileOUTFILE", "Name of file(s) to be output") do |n|
        args.output_file = n
      end

      opts.on("-y", "--yaml", "Output results in yaml format") do |n|
        args.yaml_output = n
      end

      opts.on("-j", "--json", "Output results in json format") do |n|
        args.json_output = n
      end

      opts.on("-c", "--csv", "Output results to csv file") do |n|
        args.csv_output = n
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
