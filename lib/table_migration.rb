class TableMigration
    attr_reader :name

    def initialize(name, spec)
        @name = name.to_s
        @spec = spec
    end

    def key_column
        if @spec.has_key?(:key)
            return @spec[:key]
        end
        return nil
    end

    def compare_by_key
        diffs = {
            :add => [],
            :same => [],
            :change => [],
            :create => false,
        }
        wtables = $dbw.tables
        sources = $dbr.execute("select * from #{name} order by #{key_column}")
        if wtables.include?(name)
            while row = sources.fetch_hash() do
                src_str = row.to_s
                begin
                    id = row[key_column].force_encoding("UTF-8")
                    target = $dbw.execute("select * from #{name} where #{key_column} = ?", id)
                    if row = target.fetch_hash()
                        dst_str = row.to_s
                        if src_str == dst_str
                            diffs[:same].push(id)
                        else
                            diffs[:change].push(dst_str.wdiff(src_str))
                        end
                    else
                        diffs[:add].push(src_str)
                    end
                rescue Mysql::Error
                    print "error on table #{name}: " + $!.error + "\n"
                    next
                end
            end
        else
            diffs[:create] = true
        end

        return diffs
    end
end
