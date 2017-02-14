# frozen_string_literal: true
require "spec_helper"

describe GraphQL::Argument do
  it "is validated at schema build-time" do
    query_type = GraphQL::ObjectType.define do
      name "Query"
      field :invalid, types.Boolean do
        argument :invalid, types.Float, default_value: ["123"]
      end
    end

    err = assert_raises(GraphQL::Schema::InvalidTypeError) {
      schema = GraphQL::Schema.define(query: query_type)
      schema.types
    }

    expected_error = %|Query is invalid: field "invalid" argument "invalid" default value ["123"] is not valid for type Float|
    assert_includes err.message, expected_error
  end

  it "accepts proc type" do
    argument = GraphQL::Argument.define(name: :favoriteFood, type: -> { GraphQL::STRING_TYPE })
    assert_equal GraphQL::STRING_TYPE, argument.type
  end

  it "accepts a default_value" do
    argument = GraphQL::Argument.define(name: :favoriteFood, type: GraphQL::STRING_TYPE, default_value: 'Default')
    assert_equal 'Default', argument.default_value
    assert argument.default_value?
  end

  it "accepts a default_value of nil" do
    argument = GraphQL::Argument.define(name: :favoriteFood, type: GraphQL::STRING_TYPE, default_value: nil)
    assert argument.default_value.nil?
    assert argument.default_value?
  end

  it "default_value is optional" do
    argument = GraphQL::Argument.define(name: :favoriteFood, type: GraphQL::STRING_TYPE)
    assert argument.default_value.nil?
    assert !argument.default_value?
  end

  describe "#type" do
    it "generates an input object type for the argument" do
      test_field = GraphQL::Field.define do
        name "testField"
        argument :something do
          type do
            argument :a, types.String
            argument :b, types.Int
          end
        end
      end

      generated_type = test_field.arguments["something"].type
      assert_instance_of GraphQL::InputObjectType, generated_type
      assert_equal ["a", "b"], generated_type.arguments.keys
      assert_equal "somethingInput", generated_type.name
    end

    it "accepts a custom name" do
      arg = GraphQL::Argument.define do
        name "stuff"
        type do
          name "SomethingType"
          argument :x do
            type do
              name "SomethingElseType"
              argument :y, types.Boolean
            end
          end
        end
      end

      assert_equal "SomethingType", arg.type.name
      assert_equal "SomethingElseType", arg.type.arguments["x"].type.name
      assert_equal "Boolean", arg.type.arguments["x"].type.arguments["y"].type.name
    end

    it "accepts a default value" do
      arg = GraphQL::Argument.define do
        name "stuff"
        default_value({ "x" => { "y" => false } })
        type do
          name "SomethingType"
          argument :x do
            type do
              name "SomethingElseType"
              argument :y, types.Boolean
            end
          end
        end
      end

      assert_equal false, arg.default_value["x"]["y"]
    end
  end
end
