require 'json/schema/utils'
require 'pattern-match'
using PatternMatch

module JSON
  class Schema
    class Class
      def initialize
        @properties = @properties.map { |name, properties|
          [name, get_properties(properties)]
        }.to_h
      end

      def to_json
        to_hash().to_json()
      end

      def to_hash
        check_required
        h = {}
        @attributes.each { |name, value|
          check_value(name, value, @properties[name])
          h.merge!({
            name => value.public_methods.include?(:to_hash) ? value.to_hash : value
          })
        }
        h
      end

      protected

      def []=(name, value)
        name = name.to_s
        raise ArgumentError.new("invalid attribute `#{name}'") if @properties[name].nil?
        check_value(name, value, @properties[name])
        set_value(name, value, @properties[name])
      end

      def [](name)
        @attributes[name]
      end

      private

      def set_value(name, value, properties)
        match(properties["type"] || "any") do
          with("object") {
            klass = @prefix.const_get(JSON::Schema::Utils.classify(properties["name"]))
            if value.is_a?(klass)
              @attributes[name] = value
            elsif value.is_a?(Hash)
              @attributes[name] = klass.new(value)
            else
              raise ArgumentError.new("#{name} must be a #{klass} or Hash")
            end
          }
          with("string") {
            @attributes[name] = value
            @attributes[name] = DateTime.parse(value).iso8601 if properties["format"] && properties["format"] == "date-time"
          }
          with(_) {
            @attributes[name] = value
          }
        end
      end

      def get_properties(properties)
        if properties["$ref"]
          properties.merge!(get_properties_ref(properties["$ref"])).delete_if{|k, _| k == "$ref"}
        elsif properties["oneOf"]
          properties.merge!({"oneOf" => properties["oneOf"].map { |schema|
            get_properties(schema)
          }})
        else
          properties
        end
      end

      def get_properties_ref(path)
        if path[0..1] == "#/"
          ref, name = path[2..-1].split("/").inject([@json.dup, nil]) { |acc, key|
            properties = acc[0]
            if properties && properties[key]
              [properties[key], key]
            else
              [nil, nil]
            end
          }
          raise InvalidSchemaReference.new("path") if ref.nil?
          ref.merge!({"name" => name})
        else
          warn "External ref not supported"
          {}
        end
      end

      def check_required
        @required.each do |name|
          begin
            check_value(name, @attributes[name], @properties[name])
          rescue
            raise ArgumentError.new("invalid attribut `#{name}'")
          end
        end
      end

      def check_value(name, value, properties)
        # type
        check_type(name, value, properties["type"], JSON::Schema::Utils.classify(properties["name"]))

        # enum
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), must be #{properties["enum"]}") if properties["enum"] && not(properties["enum"].include?(value))
        # multipleOf
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), must be multiple of #{properties["multipleOf"]}") if properties["multipleOf"] && not((value.to_f / properties["multipleOf"].to_f).to_i == (value.to_f / properties["multipleOf"].to_f))
        # minimum && exclusiveMinimum
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), must be >#{properties["exclusiveMinimum"] ? "" : "="} #{properties["minimum"]}") if properties["minimum"] && (properties["exclusiveMinimum"] ? properties["minimum"] >= value : properties["minimum"] > value)
        # maximum && exclusiveMaximum
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), must be <#{properties["exclusiveMaximum"] ? "" : "="} #{properties["maximum"]}") if properties["maximum"] && (properties["exclusiveMaximum"] ? properties["maximum"] <= value : properties["maximum"] < value)
        # minLength
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), size must be <= #{properties["maxLength"]}") if properties["maxLength"] && value.size > properties["maxLength"]
        # maxLength
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), size must be >= #{properties["minLength"]}") if properties["minLength"] && value.size < properties["minLength"]
        # pattern
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), don't match #{properties["pattern"]}") if properties["pattern"] && Regexp.new(properties["pattern"]).match(value).nil?

        check_array_items(name, value, properties) if value.is_a?(::Array)
      end

      def check_array_items(name, value, properties)
        # uniqueItems
        duplicate = value.detect{ |e| value.count(e) > 1 }
        raise ArgumentError.new("invalid value for `#{name}' (#{value}), value `#{duplicate}' is duplicated") if properties["uniqueItems"] && duplicate
        # items
        value.each { |v|
          check_type(name, v, properties["items"]["type"], JSON::Schema::Utils.classify(properties["name"]))
        } if properties["items"]
      end

      def check_type(name, value, type, klass)
        match(type) do
          with("any") { }
          with("array") {
            raise ArgumentError.new("#{name} must be an Array") unless value.is_a?(Array)
          }
          with("boolean") {
            raise ArgumentError.new("#{name} must be true or false") unless value.is_a?(TrueClass) || value.is_a?(FalseClass)
          }
          with("integer") {
            raise ArgumentError.new("#{name} must be an Integer") unless value.is_a?(Integer)
          }
          with("null") {
            raise ArgumentError.new("#{name} must be nil") unless value.nil?
          }
          with("number") {
            raise ArgumentError.new("#{name} must be a Numeric") unless value.is_a?(Numeric)
          }
          with("object") {
            raise ArgumentError.new("#{name} must be an #{@prefix}::#{klass}") unless (klass && value.is_a?(@prefix.const_get(klass))) || value.is_a?(Hash)
          }
          with("string") {
            raise ArgumentError.new("#{name} must be a String") unless value.is_a?(String)
          }
          with(_) { }
        end
      end
    end
  end
end
