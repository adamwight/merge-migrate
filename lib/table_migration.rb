class TableMigration < Table
    include AnalyzeTable

    attr_reader :diffs

    def execute
        strategy.each do |method|
            self.send(method)
        end
    end

    def is_shifting?
        return strategy.include?("shift_changes")
    end

    def make_additions
        if @diffs[:create]
            result = $dbr.execute("SHOW CREATE TABLE #{name}")
            sql = result.fetch.pop
            db_write(sql)
        end

        @diffs[:add].each do |item|
            item.map_keys()
            db_write("INSERT INTO #{name} SET #{set_clause(item.row)}", *item.row.values)
        end
    end

    def make_changes
        @diffs[:change].each do |item|
            item.map_keys()
            db_write("UPDATE #{name} SET #{set_clause(item.row)} WHERE #{key_where_clause}", *item.row.values, *item.id)
        end
    end

    def set_clause(row)
        return row.keys.map { |column| "#{column} = ?" }.join(", ")
    end

    def shift_changes
        @diffs[:change].each do |item|
            item.map_keys()
            db_write("INSERT INTO #{name} SET #{set_clause(item.row)}", *item.row.values)
        end
    end

    def strategy
        if @spec.include?(:strategy)
            return @spec[:strategy]
        else
            return $config[:strategy]
        end
    end
end
