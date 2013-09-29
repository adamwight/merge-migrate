#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__)
require "config/environment"

$tables = Hash[
    $config[:tables].map { |name, spec|
        [name.to_s, TableMigration.new(name, spec)]
    }
]

$dbr = DBI.connect($config[:db][:source_dsn], $config[:db][:user], $config[:db][:pass])
$dbw = DBI.connect($config[:db][:dest_dsn], $config[:db][:user], $config[:db][:pass])

# low TODO: compare Drupal version and other sanity checks

$tables.each do |_, table|
    table.analyze()
end

$tables.each do |_, table|
    table.plan()
end

dump_yaml($tables, "out.yaml")

begin
    $dbw.transaction do
        db_write("SET foreign_key_checks = 0")
        $tables.each do |_, table|
            table.execute()
        end
        if $config[:nocommit]
            raise "Aborting before commit"
        end
    end
#rescue DBI::DatabaseError => ex
ensure
    db_write("SET foreign_key_checks = 1")
end
