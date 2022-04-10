# frozen_string_literal: true

require "test_helper"

class RBSTest < Minitest::Test
  def self.test_fixture_set(name, &block)
    filepath = File.expand_path("fixtures/#{name}.txt", __dir__)
    test_fixtures(name, File.foreach(filepath, chomp: true), &block)
  end

  def self.test_fixtures(name, fixtures, &block)
    fixtures.each.with_index(1) do |fixture, index|
      source = yield fixture
      define_method("test_#{name}_#{index}") { assert_format(source) }
    end
  end

  test_fixture_set("combination") { |line| "T: #{line}" }
  test_fixture_set("constant") { |line| "T: #{line}" }
  test_fixture_set("declaration") { |line| line }
  test_fixture_set("interface") { |line| "T: #{line}" }
  test_fixture_set("literal") { |line| "T: #{line}" }
  test_fixture_set("optional") { |line| "T: #{line}" }
  test_fixture_set("plain") { |line| "T: #{line}" }
  test_fixture_set("proc") { |line| "T: #{line}" }
  test_fixture_set("record") { |line| "T: #{line}" }
  test_fixture_set("tuple") { |line| "T: #{line}" }

  test_fixture_set("generic") do |line|
    <<~RBS
      class T
        def t: #{line}
      end
    RBS
  end

  test_fixture_set("member") do |line|
    <<~RBS
      class T
        #{line}
      end
    RBS
  end

  test_fixture_set("method") do |line|
    <<~RBS
      class T
        #{line}
      end
    RBS
  end

  #-----------------------------------------------------------------------------
  # Declaration comment tests
  #-----------------------------------------------------------------------------

  fixtures = [
    "type foo = Bar",
    "class Foo\nend",
    "Foo: String",
    "$foo: String",
    "interface _Foo\nend",
    "module Foo\nend",
  ]

  test_fixtures("declarations_with_comments", fixtures) do |fixture|
    <<~RBS
      # This is a comment
      #{fixture}
    RBS
  end

  #-----------------------------------------------------------------------------
  # Member comment tests
  #-----------------------------------------------------------------------------

  fixtures = [
    "alias foo bar",
    "attr_accessor foo: Foo",
    "attr_reader foo: Foo",
    "attr_writer foo: Foo",
    "self.@foo: String",
    "@@foo: String",
    "extend Foo",
    "include Foo",
    "@foo: String",
    "def t: (T t) -> void",
    "prepend Foo",
    "private def t: (T t) -> void",
    "public attr_accessor foo: Foo",
  ]

  test_fixtures("members_with_comments", fixtures) do |fixture|
    <<~RBS
      class T
        # This is a comment
        #{fixture}
      end
    RBS
  end

  #-----------------------------------------------------------------------------
  # Declaration annotations tests
  #-----------------------------------------------------------------------------

  fixtures = [
    "type foo = Bar",
    "class Foo\nend",
    "interface _Foo\nend",
    "module Foo\nend",
  ]

  test_fixtures("declarations_with_annotations", fixtures) do |fixture|
    <<~RBS
      %a{This is an annotation.}
      #{fixture}
    RBS
  end

  #-----------------------------------------------------------------------------
  # Member annotations tests
  #-----------------------------------------------------------------------------

  fixtures = [
    "alias foo bar",
    "attr_accessor foo: Foo",
    "attr_reader foo: Foo",
    "attr_writer foo: Foo",
    "extend Foo",
    "include Foo",
    "def t: (T t) -> void",
    "prepend Foo",
    "private def t: (T t) -> void",
    "public attr_accessor foo: Foo",
  ]

  test_fixtures("members_with_annotations", fixtures) do |fixture|
    <<~RBS
      class T
        %a{This is an annotation.}
        #{fixture}
      end
    RBS
  end

  #-----------------------------------------------------------------------------
  # Multi-line tests
  #-----------------------------------------------------------------------------

  def test_interface
    assert_format(<<~RBS)
      interface _Foo
      end
    RBS
  end

  def test_interface_with_type_params
    assert_format(<<~RBS)
      interface _Foo[A, B]
      end
    RBS
  end

  def test_interface_with_bounded_type_param
    assert_format(<<~RBS)
      interface _Foo[A < B]
      end
    RBS
  end

  def test_interface_with_fancy_bounded_type_params
    assert_format(<<~RBS)
      interface _Foo[U < singleton(::Hash), V < W[X, Y]]
      end
    RBS
  end

  def test_class
    assert_format(<<~RBS)
      class Foo
      end
    RBS
  end

  def test_class_with_type_params
    assert_format(<<~RBS)
      class Foo[A, B]
      end
    RBS
  end

  def test_class_with_complicated_type_params
    assert_format(<<~RBS)
      class Foo[unchecked in A, unchecked out B, in C, out D, unchecked E, unchecked F, G, H]
      end
    RBS
  end

  def test_class_with_bounded_type_param
    assert_format(<<~RBS)
      class Foo[A < B]
      end
    RBS
  end

  def test_class_with_fancy_bounded_type_params
    assert_format(<<~RBS)
      class Foo[U < singleton(::Hash), V < W[X, Y]]
      end
    RBS
  end

  def test_class_with_annotations_that_cannot_be_switched_to_braces
    assert_format(<<~RBS)
      %a<This is {an} annotation.>
      class Foo
      end
    RBS
  end

  def test_class_with_superclass
    assert_format(<<~RBS)
      class Foo < Bar
      end
    RBS
  end

  def test_module
    assert_format(<<~RBS)
      module Foo
      end
    RBS
  end

  def test_module_with_type_params
    assert_format(<<~RBS)
      module Foo[A, B]
      end
    RBS
  end

  def test_module_with_self_types
    assert_format(<<~RBS)
      module Foo : A
      end
    RBS
  end

  def test_multiple_empty_lines
    assert_format(<<~EXPECTED, <<~ORIGINAL)
      class Foo
        A: 1
        B: 2

        C: 3
      end
    EXPECTED
      class Foo
        A: 1
        B: 2


        C: 3
      end
    ORIGINAL
  end

  #-----------------------------------------------------------------------------
  # String tests
  #-----------------------------------------------------------------------------

  def test_keeps_string_the_same_when_there_is_an_escape_sequence
    assert_format("T: \"super \\a duper\"")
  end

  def test_maintains_escape_sequences_double_quotes
    assert_format("T: \"escape sequences \\a\\b\\e\\f\\n\\r\"")
  end

  def test_maintains_escape_sequences_single_quotes
    assert_format("T: 'escape sequences \\a\\b\\e\\f\\n\\r'")
  end

  def test_double_quotes
    assert_format("T: \"foo\"")
  end

  def test_single_quotes
    assert_format("T: \"foo\"", "T: 'foo'")
  end

  #-----------------------------------------------------------------------------
  # Miscellaneous tests
  #-----------------------------------------------------------------------------

  def test_unary_plus_drops_the_plus_sign
    assert_format("T: 1", "T: +1")
  end

  def test_removes_optional_space_before_question_mark
    assert_format("T: :foo?", "T: :foo ?")
  end

  def test_proc_drops_optional_parentheses_when_there_are_no_params
    assert_format("T: ^-> void", "T: ^() -> void")
  end

  def test_proc_drops_optional_parentheses_with_block_params_when_there_are_no_params_to_the_block
    assert_format("T: ^{ -> void } -> void", "T: ^{ () -> void } -> void")
  end

  def test_emoji
    assert_format("T: { \"🌼\" => Integer }")
  end

  def test_kanji
    assert_format("T: { \"日本語\" => Integer }")
  end

  private

  def assert_format(expected, original = expected)
    # First, check that the formatting is as expected.
    formatted = SyntaxTree::RBS.format(original)
    assert_equal(expected.strip, formatted.strip)

    # Next, check that the formatting is idempotent.
    formatted = SyntaxTree::RBS.format(formatted)
    assert_equal(expected.strip, formatted.strip)

    # Next, check that the pretty-print functions are implemented all of the way
    # down the tree.
    formatter = PP.new(+"")
    SyntaxTree::RBS.parse(original).pretty_print(formatter)

    formatter.flush
    refute_includes(formatter.output, "#")
  end
end
