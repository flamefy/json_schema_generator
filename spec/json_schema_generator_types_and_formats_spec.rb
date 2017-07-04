require "spec_helper"

describe JSON::Schema::Generator do
  let(:schema) {
    File.join(File.expand_path(File.dirname(__FILE__)), "types.json")
  }

  before do
    JSON::Schema::Generator.generate(schema, root_class: "Types", module: "TestTypes")
  end

  it "should have new defined classes" do
    expect(Object.const_defined?(TestTypes::Types.to_s)).to eq(true)
  end

  it "should validate string" do
    expect(TestTypes::Types.new({"string" => "Hello World"}).string).to eq("Hello World")
    expect {
      TestTypes::Types.new({"string" => 123})
    }.to raise_error(ArgumentError, "string must be a String")
    expect {
      TestTypes::Types.new({"string" => 12.3})
    }.to raise_error(ArgumentError, "string must be a String")
    expect {
      TestTypes::Types.new({"string" => true})
    }.to raise_error(ArgumentError, "string must be a String")
    expect {
      TestTypes::Types.new({"string" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "string must be a String")
  end

  it "should validate string with date-time format" do
    expect(TestTypes::Types.new({"datetime" => "2017-01-01 12:23:34"}).datetime).to eq("2017-01-01T12:23:34.000+00:00")
    expect {
      TestTypes::Types.new({"datetime" => "Hello World"})
    }.to raise_error(ArgumentError, "invalid date")
    expect {
      TestTypes::Types.new({"datetime" => 123})
    }.to raise_error(ArgumentError, "datetime must be a String")
    expect {
      TestTypes::Types.new({"datetime" => 12.3})
    }.to raise_error(ArgumentError, "datetime must be a String")
    expect {
      TestTypes::Types.new({"datetime" => true})
    }.to raise_error(ArgumentError, "datetime must be a String")
    expect {
      TestTypes::Types.new({"datetime" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "datetime must be a String")
  end

  it "should validate string with uri format" do
    expect(TestTypes::Types.new({"uri" => "http://google.com"}).uri).to eq("http://google.com")
    expect {
      TestTypes::Types.new({"uri" => "Hello World"})
    }.to raise_error(ArgumentError, "uri must be an URI")
    expect {
      TestTypes::Types.new({"uri" => 123})
    }.to raise_error(ArgumentError, "uri must be a String")
    expect {
      TestTypes::Types.new({"uri" => 12.3})
    }.to raise_error(ArgumentError, "uri must be a String")
    expect {
      TestTypes::Types.new({"uri" => true})
    }.to raise_error(ArgumentError, "uri must be a String")
    expect {
      TestTypes::Types.new({"uri" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "uri must be a String")
  end

  it "should validate string with uuid format" do
    expect(TestTypes::Types.new({"uuid" => "3dd43003-4950-4eb1-b544-63539181e856"}).uuid).to eq("3dd43003-4950-4eb1-b544-63539181e856")
    expect {
      TestTypes::Types.new({"uuid" => "Hello World"})
    }.to raise_error(ArgumentError, "uuid must be an UUID")
    expect {
      TestTypes::Types.new({"uuid" => 123})
    }.to raise_error(ArgumentError, "uuid must be a String")
    expect {
      TestTypes::Types.new({"uuid" => 12.3})
    }.to raise_error(ArgumentError, "uuid must be a String")
    expect {
      TestTypes::Types.new({"uuid" => true})
    }.to raise_error(ArgumentError, "uuid must be a String")
    expect {
      TestTypes::Types.new({"uuid" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "uuid must be a String")
  end

  it "should validate integer" do
    expect(TestTypes::Types.new({"integer" => 123}).integer).to eq(123)
    expect {
      TestTypes::Types.new({"integer" => "Hello World"})
    }.to raise_error(ArgumentError, "integer must be an Integer")
    expect {
      TestTypes::Types.new({"integer" => 12.3})
    }.to raise_error(ArgumentError, "integer must be an Integer")
    expect {
      TestTypes::Types.new({"integer" => true})
    }.to raise_error(ArgumentError, "integer must be an Integer")
    expect {
      TestTypes::Types.new({"integer" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "integer must be an Integer")
  end

  it "should validate number" do
    expect(TestTypes::Types.new({"number" => 12.3}).number).to eq(12.3)
    expect(TestTypes::Types.new({"number" => 123}).number).to eq(123)
    expect {
      TestTypes::Types.new({"number" => "Hello World"})
    }.to raise_error(ArgumentError, "number must be a Numeric")
    expect {
      TestTypes::Types.new({"number" => true})
    }.to raise_error(ArgumentError, "number must be a Numeric")
    expect {
      TestTypes::Types.new({"number" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "number must be a Numeric")
  end

  it "should validate single" do
    expect(TestTypes::Types.new({"single" => 12.3}).single).to eq(12.3)
    expect {
      TestTypes::Types.new({"single" => 123})
    }.to raise_error(ArgumentError, "single must be a single64")
    expect {
      TestTypes::Types.new({"single" => "Hello World"})
    }.to raise_error(ArgumentError, "single must be a Numeric")
    expect {
      TestTypes::Types.new({"single" => true})
    }.to raise_error(ArgumentError, "single must be a Numeric")
    expect {
      TestTypes::Types.new({"single" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "single must be a Numeric")
  end

  it "should validate double" do
    expect(TestTypes::Types.new({"double" => 12.3}).double).to eq(12.3)
    expect {
      TestTypes::Types.new({"double" => 123})
    }.to raise_error(ArgumentError, "double must be a double64")
    expect {
      TestTypes::Types.new({"double" => "Hello World"})
    }.to raise_error(ArgumentError, "double must be a Numeric")
    expect {
      TestTypes::Types.new({"double" => true})
    }.to raise_error(ArgumentError, "double must be a Numeric")
    expect {
      TestTypes::Types.new({"double" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "double must be a Numeric")
  end

  it "should validate boolean" do
    expect(TestTypes::Types.new({"boolean" => true}).boolean).to eq(true)
    expect(TestTypes::Types.new({"boolean" => false}).boolean).to eq(false)
    expect {
      TestTypes::Types.new({"boolean" => 123})
    }.to raise_error(ArgumentError, "boolean must be true or false")
    expect {
      TestTypes::Types.new({"boolean" => "Hello World"})
    }.to raise_error(ArgumentError, "boolean must be true or false")
    expect {
      TestTypes::Types.new({"boolean" => 12.3})
    }.to raise_error(ArgumentError, "boolean must be true or false")
    expect {
      TestTypes::Types.new({"boolean" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "boolean must be true or false")
  end

  it "should validate array of integer" do
    expect(TestTypes::Types.new({"array_of_integer" => [1, 2 ,3]}).array_of_integer).to eq([1, 2, 3])
    expect {
      TestTypes::Types.new({"array_of_integer" => ["a", "b", "c"]})
    }.to raise_error(ArgumentError, "array_of_integer must be an Integer")
    expect {
      TestTypes::Types.new({"array_of_integer" => 123})
    }.to raise_error(ArgumentError, "array_of_integer must be an Array")
    expect {
      TestTypes::Types.new({"array_of_integer" => "Hello World"})
    }.to raise_error(ArgumentError, "array_of_integer must be an Array")
    expect {
      TestTypes::Types.new({"array_of_integer" => 12.3})
    }.to raise_error(ArgumentError, "array_of_integer must be an Array")
    expect {
      TestTypes::Types.new({"array_of_integer" => {"hello" => "world"}})
    }.to raise_error(ArgumentError, "array_of_integer must be an Array")
  end
end
