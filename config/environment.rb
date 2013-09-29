config_paths = [
    File.dirname(__FILE__),
]

require 'rubygems'

gem 'dbi'
gem 'dbd-mysql'
require 'dbi'

gem 'wdiff'
require 'wdiff'

gem 'activesupport'

require "lib/analyze_table"
require "lib/db"
require "lib/recursive_symdesym"
require "lib/row"
require "lib/table"
require "lib/table_migration"
require "lib/yaml"

config_files = config_paths.map {|d|
    Dir[File.join(d, "*.yaml")].sort
}.flatten
$config = load_all_yamls(config_files)
