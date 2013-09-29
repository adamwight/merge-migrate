def db_write(sql, *params)
    if $config[:debug]
        print sql, params, "\n"
    end

    $dbw.execute(sql, *params)
end

# TODO too bad $dbr.columns is borken
