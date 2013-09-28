require 'active_support/core_ext/hash/keys'
# FIXME: deprecate when deep_symbolize_keys! is released

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

  def recursively_stringify_keys!
    self.stringify_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_stringify_keys!
      elsif v.is_a? Array
        v.recursively_stringify_keys!
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

  def recursively_stringify_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_stringify_keys!
      elsif item.is_a? Array
        item.recursively_stringify_keys!
      end
    end
  end
end
