require "spec_helper"

describe JSON::Schema::Generator do
  let(:schema) {
    File.join(File.expand_path(File.dirname(__FILE__)), "simple.json")
  }

  it "has a version number" do
    expect(JSON::Schema::Generator::VERSION).not_to be nil
  end

  describe "generate classes" do
    before do
      JSON::Schema::Generator.generate(schema, root_class: "User", module: "Test")
    end

    it "should have new defined classes" do
      expect(Object.const_defined?(Test::User.to_s)).to eq(true)
      expect(Object.const_defined?(Test::Address.to_s)).to eq(true)
    end

    it "create a new user from hash" do
      user = Test::User.new({
        "firstname" => "John",
        "lastname" => "Doe",
        "age" => 32,
        "created_at" => "Mon 19 June, 13:23:17",
        "type" => "human",
        "billing_address" => {
          "street_address" => "Diagon Alley",
          "city" => "London",
          "zip" => "EC2R 6AB"
        }
      })
      expect(user.valid?).to be(true)
      expect(user.firstname).to eq("John")
      expect(user.lastname).to eq("Doe")
      expect(user.age).to eq(32)
      expect(user.created_at).to eq("2017-06-19T13:23:17.000+00:00")
      expect(user.type).to eq("human")
      expect(user.billing_address.class).to eq(Test::Address)
      expect(user.shipping_address).to be_nil
      expect(user.billing_address.street_address).to eq("Diagon Alley")
      expect(user.billing_address.city).to eq("London")
      expect(user.billing_address.zip).to eq("EC2R 6AB")
      expect(user.to_hash()).to eq({
        "firstname" => "John",
        "lastname" => "Doe",
        "age" => 32,
        "created_at" => "2017-06-19T13:23:17.000+00:00",
        "type" => "human",
        "billing_address" => {
          "street_address" => "Diagon Alley",
          "city" => "London",
          "zip" => "EC2R 6AB"
        }
      })
    end

    it "does not validate an incomplete user" do
      user = Test::User.new({
        "lastname" => "Doe",
        "age" => 32,
        "created_at" => "Mon 19 June, 13:23:17",
        "type" => "human",
        "billing_address" => {
          "street_address" => "Diagon Alley",
          "city" => "London",
          "zip" => "EC2R 6AB"
        }
      })
      expect(user.valid?).to be(false)
      expect{user.valid!}.to raise_error(ArgumentError, "firstname must be a String")
    end
  end
end
