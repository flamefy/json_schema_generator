require "spec_helper"

describe JSON::Schema::Generator do
  let(:schema) {
    File.join(File.expand_path(File.dirname(__FILE__)), "array.json")
  }

  describe "generate classes with arrays" do
    before do
      JSON::Schema::Generator.generate(schema, root_class: "User", module: "TestArray")
    end

    it "should have new defined classes" do
      expect(Object.const_defined?(TestArray::User.to_s)).to eq(true)
      expect(Object.const_defined?(TestArray::Address.to_s)).to eq(true)
      expect(Object.const_defined?(TestArray::Coordinates.to_s)).to eq(true)
    end

    it "create a new user from hash" do
      user = TestArray::User.new({
        "human" => false,
        "firstname" => "John",
        "lastname" => "Doe",
        "area" => [
          [{"x" => 0, "y" => 0}, {"x" => 10, "y" => 10}],
          [{"x" => 20, "y" => 20}, {"x" => 30, "y" => 30}]
        ],
        "addresses" => [
          {
            "street_address" => "Diagon Alley",
            "city" => "London",
            "zip" => "EC2R 6AB"
          },
          {
            "street_address" => "King's Cross Station",
            "city" => "London",
            "zip" => "EC2R 6AB"
          }
        ]
      })
      expect(user.firstname).to eq("John")
      expect(user.lastname).to eq("Doe")
      expect(user.addresses[0]).to be_a(TestArray::Address)
      expect(user.addresses.size).to eq(2)
      expect(user.addresses[0].street_address).to eq("Diagon Alley")
      expect(user.area).to be_a(Array)
      expect(user.area.size).to eq(2)
      expect(user.area[0]).to be_a(Array)
      expect(user.area[0].size).to eq(2)
      expect(user.area[0][0]).to be_a(TestArray::Coordinates)
      expect(user.area[0][0].x).to eq(0)
      expect(user.to_hash()).to eq({
        "human" => false,
        "firstname" => "John",
        "lastname" => "Doe",
        "area" => [
          [{"x" => 0, "y" => 0}, {"x" => 10, "y" => 10}],
          [{"x" => 20, "y" => 20}, {"x" => 30, "y" => 30}]
        ],
        "addresses" => [
          {
            "street_address" => "Diagon Alley",
            "city" => "London",
            "zip" => "EC2R 6AB"
          },
          {
            "street_address" => "King's Cross Station",
            "city" => "London",
            "zip" => "EC2R 6AB"
          }
        ]
      })
    end

    it "create a new user with an empty area" do
      user = TestArray::User.new({
        "firstname" => "John",
        "lastname" => "Doe",
        "area" => [],
        "addresses" => [
          {
            "street_address" => "Diagon Alley",
            "city" => "London",
            "zip" => "EC2R 6AB"
          },
          {
            "street_address" => "King's Cross Station",
            "city" => "London",
            "zip" => "EC2R 6AB"
          }
        ]
      })
      expect(user.firstname).to eq("John")
      expect(user.area).to eq([])
      expect(user.human).to eq(true)
    end

    it "create a new user with an empty area not set" do
      user = TestArray::User.new({
        "firstname" => "John",
        "lastname" => "Doe",
        "addresses" => [
          {
            "street_address" => "Diagon Alley",
            "city" => "London",
            "zip" => "EC2R 6AB"
          },
          {
            "street_address" => "King's Cross Station",
            "city" => "London",
            "zip" => "EC2R 6AB"
          }
        ]
      })
      expect(user.firstname).to eq("John")
      expect(user.area).to eq([])
      expect(user.human).to eq(true)
    end
  end
end
