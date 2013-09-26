#!/usr/bin/env ruby

def require_relative(path)
  $rootdir = File.dirname(__FILE__)
  require File.join($rootdir, path.to_str)
end

require_relative("config/environment")

tables = $config[:tables]
$dbr = DBI.connect($config[:db][:source_dsn], $config[:db][:user], $config[:db][:pass])
$dbw = DBI.connect($config[:db][:dest_dsn], $config[:db][:user], $config[:db][:pass])

# columns to be shifted
$mappings = {}

# row differences
$diffs = {}

# low TODO: compare Drupal version

def compare_by_key(table, key_column, spec)
    $diffs[table] = {
        'add' => [],
        'same' => [],
        'change' => [],
    }
    sources = $dbr.query("select * from #{table} order by #{key_column}")
    sources.each_hash do |row|
        src_json = YAML.dump(row)
        id_s = $dbw.quote(row[key_column])
        begin
            target = $dbw.query("select * from #{table} where #{key_column} = #{id_s}")
        rescue Mysql::Error
            print "error on table #{table}: " + $!.error + "\n"
            next
        end
        if target.num_rows() == 0
            $diffs[table]['add'].push(src_json)
        else
            dst_json = YAML.dump(target.fetch_hash())
            if src_json == dst_json
                $diffs[table]['same'].push(id_s)
            else
                $diffs[table]['change'].push(dst_json.wdiff(src_json))
            end
        end
    end
end

tables.each do |table, spec|
    print "Checking table #{table}...\n"
    spec.each do |key, value|
        if key == 'id' || key == 'key'
            compare_by_key(table, value, spec)
        end

        if $mappings.has_key?(value)
            qualified_column = "#{table}.#{key}"
            $mappings[qualified_column] = $mappings[value]
        end
    end
end

out = YAML.dump({
    'diffs' => $diffs,
    'mappings' => $mappings,
})
File.open("out.yaml", 'w') { |f| f.write(out) }
