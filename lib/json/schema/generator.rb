require 'json/schema/class'
require 'json/schema/utils'
require 'open-uri'
require 'pattern-match'
require 'json'
using PatternMatch

module JSON
  class Schema
    class Generator
      class << self
        def generate(schema, **options)
          JSON::Schema::Generator.new(schema, options).generate
        end
      end

      attr_reader :klasses

      # Options :
      # * root_class : string
      # * module : string | nil
      # * ignore_unknown_attributes
      # * camelcase_attributes
      def initialize(schema, **options)
        @options = {root_class: "root", module: nil, ignore_unknown_attributes: true, camelcase_attributes: false}.merge!(options)
        @schema = schema
        @json = read_schema(schema)
        @klasses = {}
      end

      def generate
        generate_class(@options[:root_class], @json["properties"], @json["required"] || [])
        @klasses
      end

      private

      def generate_class(name, properties, required)
        prefix = unless @options[:module].nil?
                   prefix = JSON::Schema::Utils.classify(@options[:module])
                   if Object.const_defined?(prefix)
                     Object.const_get(prefix)
                   else
                     Object.const_set(prefix, Module.new)
                   end
                 else
                   Object
                 end
        ignore_unknown_attributes = @options[:ignore_unknown_attributes]
        camelcase_attributes = @options[:camelcase_attributes]
        klass_name = JSON::Schema::Utils.classify(name)
        unless prefix.const_defined?(klass_name)
          klass = ::Class.new(JSON::Schema::Class)
          json = @json
          klass.class_eval do
            define_method(:initialize) do |values = {}|
              @properties = properties
              @json = json
              @ignore_unknown_attributes = ignore_unknown_attributes
              @camelcase_attributes = camelcase_attributes
              @required = required
              @attributes = {}
              super()
              @prefix = prefix
              values.each { |property, value|
                if camelcase_attributes
                  self[property.to_s.gsub(/_(.)/) { "#{$1.upcase}" }] = value
                else
                  self[property.to_s] = value
                end
              }
            end

            properties.keys.each do |property|
              define_method("#{property}=".to_sym) do |value|
                self[property.to_s] = value
              end

              define_method(property.to_sym) do
                self[property.to_s]
              end
            end
          end
          prefix.const_set(klass_name, klass)
          final = prefix.const_get(klass_name)
          @klasses[final.to_s]=final
          generate_ref_classes(properties)
        end
      end

      def generate_ref_classes(properties)
        properties.each do |_, definition|
          definition["oneOf"].each do |one|
            generate_ref_class(one["$ref"]) if one["$ref"] and (one["type"].nil? or one["type"] == "object")
          end if definition["oneOf"]
          generate_ref_class(definition["$ref"]) if definition["$ref"] and (definition["type"].nil? or definition["type"] == "object")
          generate_items_ref_classes(definition["items"]) if definition["items"]
        end
      end

      def generate_items_ref_classes(definition)
        generate_items_ref_classes(definition["items"]) if definition["items"]
        generate_ref_class(definition["$ref"]) if definition["$ref"] and (definition["type"].nil? or definition["type"] == "object")
      end

      def generate_ref_class(path)
        if path[0..1] == "#/"
          ref, name = path[2..-1].split("/").inject([@json.dup, nil]) { |acc, key|
            properties = acc[0]
            if properties && properties[key]
              [properties[key], key]
            else
              [nil, nil]
            end
          }
          generate_class(name, ref["properties"], ref["required"] || []) if not ref.nil? and (ref["type"].nil? or ref["type"] == "object")
        else
          warn "External ref not supported"
        end
      end

      def read_schema(schema)
        match(schema) do
          with(String) { read_json_or_uri(schema) }
          with(Hash) {
            @uri = :inline
            schema
          }
          with(_other) {
            raise JSON::Schema::InvalidJSONSchemaError.new(
              "invalid schema type, must be String or Hash"
            )
          }
        end
      end

      def read_json_or_uri(schema)
        begin
          @uri = schema
          read_json(open(schema).read)
        rescue
          @uri = :inline
          read_json(schema)
        end
      end

      def read_json(data)
        begin
          ::JSON.parse(data)
        rescue JSON::ParserError => e
          raise JSON::Schema::JSONParseError.new(e.message)
        end
      end
    end
  end
end

