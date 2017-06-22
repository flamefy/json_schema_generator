module JSON
  class Schema
    class InvalidJSONSchemaError < StandardError
    end

    class JSONParseError < StandardError
    end

    class InvalidSchemaReference < StandardError
    end
  end
end
