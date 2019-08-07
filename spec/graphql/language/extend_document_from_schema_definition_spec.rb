# frozen_string_literal: true
require "spec_helper"

describe GraphQL::Language::DocumentFromSchemaDefinition do
  let(:subject) { GraphQL::Language::DocumentFromSchemaDefinition }

  describe "#document" do
    let(:schema_idl) { <<-GRAPHQL
      scalar SomeScalar
      extend scalar SomeScalar @foo

      type Foo {
        name: String
      }

      type User {
        name: String
      }

      type Bar {
        name: String
      }

      union SomeUnion = User | Foo
      extend union SomeUnion = Bar

      extend type User {
        email: String!
      }

      interface SomeInterface {
        otherField: String
      }

      extend interface SomeInterface {
        newField: String
      }

      input SomeInput {
        fooArg: String
        newField: String
      }

      extend input SomeInput {
        newField: String
      }

      enum SomeEnum {
        ONE
      }

      extend enum SomeEnum {
        NEW_ENUM
      }

      type Query {
        user: User
      }

      GRAPHQL
    }

    let(:expected_document) { GraphQL.parse(schema_idl) }
    let(:schema) { GraphQL::Schema.from_definition(schema_idl) }

    let(:document) {
      subject.new(
        schema
      ).document
    }

    it "returns the IDL without introspection, built ins and schema root" do
      assert equivalent_node?(expected_document, document)
    end

    it "print GraphQL::Language::Document with extend" do
      document = GraphQL.parse(schema_idl)
      GraphQL::Language::Printer.new.print(document)
    end

    it "generates GraphQL::Language::Document from the GraphQL::Schema build" do
    end
  end

  private

  def equivalent_node?(expected, node)
    return false unless expected.is_a?(node.class)

    if expected.respond_to?(:children) && expected.respond_to?(:scalars)
      children_equal = expected.children.all? do |expected_child|
        node.children.find { |child| equivalent_node?(expected_child, child) }
      end

      scalars_equal = expected.children.all? do |expected_child|
        node.children.find { |child| equivalent_node?(expected_child, child) }
      end

      children_equal && scalars_equal
    else
      expected == node
    end
  end
end
