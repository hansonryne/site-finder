require_relative 'site_find'
require 'oj'

test = SITEFIND::Target.new("google.com")
puts Oj::dump test, indent: 2
