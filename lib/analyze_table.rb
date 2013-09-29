module AnalyzeTable
    attr_reader :diffs, :shift

    def analyze
        print "Checking table #{name}...\n"

        @diffs = {
            :add => [],
            :same => [],
            :change => [],
            :create => false,
        }
        @shift = {}

        if key_column
            compare_by_key()

            if is_shifting?
                min = max_target_id + 1
                @shift[key_column] = min
                # FIXME fix autoincrement
            end

            if not @diffs[:change]
                #print "... safe to merge"
            else
                #print "... requires remapping or conflict resolution\n"
            end
        else
            print "... unable to compare data\n"
        end
    end

    def compare_by_key
        target_tables = $dbw.tables

        each_source_row do |source_row|
            if target_tables.include?(name)
                if target_row = find_target_row(source_row.id)
                    compare_rows(source_row, target_row)
                else
                    @diffs[:add].push(AddedRow.new(source_row))
                end
            else
                @diffs[:create] = true
                @diffs[:add].push(AddedRow.new(source_row))
            end
        end
    end

    def compare_rows(target_row, source_row)
        if source_row == target_row
            @diffs[:same].push(source_row.id)
        else
            @diffs[:change].push(ChangedRow.new(target_row, source_row))
        end
    end

    def each_source_row(&p)
        result = $dbr.execute("SELECT * FROM #{name} ORDER BY #{key_order_by_clause}")

        while source_row = result.fetch_hash() do
            row = Row.new(self, source_row)

            if @spec.include?(:include)
                if not @spec[:include].include?(row.id.to_i)
                    next
                end
            end
            if @spec.include?(:exclude)
                if @spec[:exclude].include?(row.id.to_i)
                    next
                end
            end
            if @spec.include?(:last_merged)
                if @spec[:last_merged].to_i >= row.id.to_i
                    next
                end
            end

            yield(row)
        end
    end

    def find_target_row(id)
        result = $dbw.execute("SELECT * FROM #{name} WHERE #{key_where_clause}", *id)
        row = result.fetch_hash()
        if row
            return Row.new(self, row)
        else
            return nil
        end
    end

    def max_target_id
        if key_column.is_a?(Array)
            #TODO: or if it's a string key
            raise "Can't simply shift table #{name} cos it has a multi-column primary key"
        else
            result = $dbw.execute("SELECT MAX(#{key_column}) FROM #{name}")
            return result.fetch().pop().to_i
        end
    end

    def plan
        if @spec.include?(:foreign_keys)
            @spec[:foreign_keys].each do |my_column, other|
                other_table, other_column = other.split(".")
                @shift[my_column.to_s] = $tables[other_table].shift[other_column].to_i
            end
        end
    end
end
