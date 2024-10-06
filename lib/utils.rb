module Utils
  # Utility to set the ALL for lists of constants found throughout the codebase
  def self.all_constants_in(klass)
    klass.constants.
      flat_map { |const| klass.const_get(const) }.
      reject { |const| const.is_a?(Enumerable) }.
      uniq.
      sort_by(&:to_s).freeze
  end
end
