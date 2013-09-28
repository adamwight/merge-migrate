#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__)
require "config/environment"

tables = $config[:tables].map { |name, spec| TableMigration.new(name, spec) }
$dbr = DBI.connect($config[:db][:source_dsn], $config[:db][:user], $config[:db][:pass])
$dbw = DBI.connect($config[:db][:dest_dsn], $config[:db][:user], $config[:db][:pass])

# columns to be shifted
$mappings = {}

# row differences
$diffs = {}

# low TODO: compare Drupal version

tables.each do |table|
    print "Checking table #{table.name}...\n"
    if table.key_column
        $diffs[table.name] = diffs = table.compare_by_key()
        if not diffs[:change]
            print "... safe to merge"
        else
            print "... requires remapping or conflict resolution\n"
        end
    end

    #when :strategy
end

# TODO: phase 2
#if $mappings.has_key?(value)
#    # copy the mapping from the foreign key table
#    qualified_column = "#{table}.#{key}"
#    $mappings[qualified_column] = $mappings[value]
#    $mappings[qualified_column]['alias'] = value
#else
#    raise "ERROR: No mapping found for #{qualified_column}."
#end

def max_remap(table, spec)
    key_column = spec[:key]
    wmax = $dbw.execute("SELECT MAX #{key_column} FROM #{table}")
    $mappings["#{table}.#{key_column}"] = {
        'shift' => wmax,
    }
end

dump_yaml({
    :diffs => $diffs,
    :mappings => $mappings,
}, "out.yaml")
