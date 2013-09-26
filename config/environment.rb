config_paths = [
    "#{$rootdir}/config",
]

require 'rubygems'

# you will need ruby1.8-dev and libmysqlclient-dev

gem 'dbi'
gem 'dbd-mysql'
require 'dbi'

gem 'wdiff'
require 'wdiff'

gem 'activesupport'
require_relative 'lib/ez_opts.rb'

config_files = config_paths.map {|d|
    #Dir[File.join(d, "**", "*.yml")].sort
    Dir[File.join(d, "*.yaml")].sort
}.flatten
$config = load_yaml(config_files)
