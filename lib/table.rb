class Table
    attr_reader :name, :spec

    def ignored_columns
        if @spec.include?(:ignore)
            return @spec[:ignore].map { |column| column.to_s }
        else
            return nil
        end
    end

    def initialize(name, spec)
        @name = name.to_s
        @spec = spec
    end

    def key_column
        if @spec.include?(:key)
            return @spec[:key]
        end
        return nil
    end

    def key_where_clause
        if key_column.is_a?(Array)
            return key_column.map { |column| "#{column} = ?" }.join(" AND ")
        else
            return "#{key_column} = ?"
        end
    end

    def key_order_by_clause
        if key_column.is_a?(Array)
            return key_column.join(", ")
        else
            return key_column
        end
    end
end
