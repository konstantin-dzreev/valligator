require_relative '../../test_helper'


class TestSpeaks < Minitest::Test
  include Valligator::Helper

  def error
    Valligator::ValidationError
  end


  def test_that__speaks__fails_on_wrong_number_of_arguments
    expected = "wrong number of arguments (0 for 1..Infinity) at `testee#1.speaks'"
    err = assert_raises(ArgumentError) { v(:a).speaks }
    assert_equal expected, err.message
  end


  def test_that__speaks__fails_on_wrong_argument_type
    expected = "wrong argument type (arg#1 is a NilClass instead of Symbol) at `testee#1.speaks'"
    err = assert_raises(ArgumentError) { v(:a).speaks(nil) }
    assert_equal expected, err.message
  end


  def test_that__speaks__returns_an_instance_of_valligator
    assert_instance_of Valligator, v(:a).speaks(:to_s)
  end


  def test_that__speaks__passes_when_there_is_a_match
    v(:a).speaks(:to_s)
    v(:a).speaks(:to_s, :size)
    v(:a).speaks(:to_s).speaks(:size)
  end


  def test_that__speaks__fails_when_there_is_no_match
    assert_raises(error) { v(:a).speaks(:to_i) }
    assert_raises(error) { v(:a).speaks(:to_s, :foo) }
    assert_raises(error) { v(:a).speaks(:to_s).speaks(:foo) }
  end


  def test_that__does_not_speak__passes_when_there_is_no_match
    v(:a).does_not_speak(:foo)
    v(:a).does_not_speak(:foo, :boo)
    v(:a).does_not_speak(:foo).does_not_speak(:boo)
  end


  def test_that__does_not_speak__fails_when_there_is_a_match
    assert_raises(error) { v(:a).does_not_speak(:to_s) }
    assert_raises(error) { v(:a).does_not_speak(:foo, :to_s) }
    assert_raises(error) { v(:a).does_not_speak(:foo).does_not_speak(:to_s) }
  end

end