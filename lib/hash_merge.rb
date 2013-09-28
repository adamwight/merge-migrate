require 'active_support/core_ext/hash/deep_merge'

class Hash
  def merge(other)
    deep_merge!(other)
  end
end
