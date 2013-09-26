require 'yaml'

require 'active_support/core_ext/hash/deep_merge'
class Hash
  def merge(other)
    deep_merge!(other)
  end
end

require 'active_support/core_ext/hash/keys'
class Hash
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end
end

class Array
  def recursively_symbolize_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_symbolize_keys!
      elsif item.is_a? Array
        item.recursively_symbolize_keys!
      end
    end
  end
end

def load_yaml(path)
  if path.is_a? Array
    path.reduce({}) do |memo, f|
      memo.merge(load_yaml(f))
    end
  else
    YAML.load(File.open(path, "r")).recursively_symbolize_keys!
  end
end
