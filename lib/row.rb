class Row
    attr_reader :id, :row, :table

    def ==(other)
        if ignore = @table.ignored_columns
            cut_row = @row.reject { |key, value| return ignore.include?(key) }
            cut_other = other.row.reject { |key, value| return ignore.include?(key) }
            return cut_row == cut_other
        else
            return @row == other.row
        end
    end

    def initialize(table, data)
        @table = table # yuck
        if data.is_a?(Row)
            @id = data.id
            @row = data.row
        elsif data.is_a?(Hash)
            @row = data
            @id = key_extract
        end
    end

    def key_extract
        # FIXME encoding kludge
        if @table.key_column.is_a?(Array)
            return @table.key_column.map { |column| @row[column].force_encoding("UTF-8") }
        else
            return @row[@table.key_column].force_encoding("UTF-8")
        end
    end

    def map_keys
        @table.shift.each do |column, shift|
            @row[column] = @row[column].to_i + shift
        end
    end

    def to_s
        return @row.to_s
    end

    def encode_with(coder)
        coder.map = @row
    end
end

class AddedRow < Row
    def initialize(row)
        super(row.table, row)
    end
end

class ChangedRow < Row
    attr_reader :diffs

    def initialize(dst, src)
        super(src.table, src)
        @orig = dst
        @diffs = @orig.to_s.wdiff(@row.to_s)
    end

    def encode_with(coder)
        coder.scalar = @diffs
    end
end
