require 'yaml'

def load_all_yamls(path)
    if path.is_a? Array
        path.reduce({}) do |memo, f|
            memo.merge(load_yaml(f))
        end
    else
        load_yaml(path)
    end
end

def load_yaml(path)
    YAML.load(File.open(path, "r")).recursively_symbolize_keys!
end

def dump_yaml(data, path)
    if data.is_a?(Hash) or data.is_a?(Array)
        data.recursively_stringify_keys!
    end
    out = YAML.dump(data)
    File.open(path, 'w') { |f| f.write(out) }
end
