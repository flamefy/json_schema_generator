module JSON
  class Schema
    class Utils
      class << self
        def classify(string)
          return nil unless string.is_a?(::String)
          return string if string =~ /^[A-Z]/
          string.dup.split('_').collect(&:capitalize).join
        end
      end
    end
  end
end
