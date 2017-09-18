require_relative '../../test_helper'


class TestIsInstanceOf < Minitest::Test
  include Valligator::Helper

  def error
    Valligator::ValidationError
  end


  def test_that__is_instance_of__fails_on_wrong_number_of_arguments
    expected = "wrong number of arguments (0 for 1..Infinity) at `testee#1.is_instance_of'"
    err = assert_raises(ArgumentError) { v(:a).is_instance_of }
    assert_equal expected, err.message
  end


  def test_that__is_instance_of__fails_on_wrong_argument_type
    expected = "wrong argument type (arg#1 is a Fixnum instead of Class) at `testee#1.is_instance_of'"
    err = assert_raises(ArgumentError) { v(:a).is_instance_of(1) }
    assert_equal expected, err.message
  end


  def test_that__is_instance_of__returns_an_instance_of_valligator
    assert_instance_of Valligator, v(:a).is_instance_of(Symbol)
  end


  def test_that__is_instance_of__passes_when_there_is_a_match
    v(:a).is_instance_of(Symbol)
    v(:a).is_instance_of(String, Symbol)
    v(:a).is_instance_of(Symbol).is_instance_of(Symbol)
  end


  def test_that__is_instance_of__fails_when_there_is_no_match
    assert_raises(error) { v(:a).is_instance_of(String) }
    assert_raises(error) { v(:a).is_instance_of(String, Integer) }
    assert_raises(error) { v(:a).is_instance_of(Symbol).is_instance_of(String) }
  end


  def test_that__is_not_instance_of__passes_when_there_is_no_match
    v(:a).is_not_instance_of(String)
    v(:a).is_not_instance_of(String, Integer)
    v(:a).is_not_instance_of(String).is_not_instance_of(NilClass)
  end


  def test_that__is_not_instance_of__fails_when_there_is_a_match
    assert_raises(error) { v(:a).is_not_instance_of(Symbol) }
    assert_raises(error) { v(:a).is_not_instance_of(String, Symbol) }
    assert_raises(error) { v(:a).is_not_instance_of(String).is_not_instance_of(Symbol) }
  end

end