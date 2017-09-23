require_relative '../../test_helper'


class TestErrors < Minitest::Test
  include Valligator::Helper


  def error
    Valligator::ValidationError
  end


  #-------------------------------------
  # is_kind_of
  #-------------------------------------


  def test__is_kind_of__error__single
    expected = "`testee#1': should not be Symbol"
    err = assert_raises(error) { v(:foo).is_kind_of(String) }
    assert_equal expected, err.message
  end


  def test__is_kind_of__error__multiple
    expected = "`testee#1': should not be Symbol"
    err = assert_raises(error) { v(:foo).is_kind_of(String, Hash, Array) }
    assert_equal expected, err.message
  end


  def test__is_not_kind_of__error__single
    expected = "`testee#1': should not be Symbol"
    err = assert_raises(error) { v(:foo).is_not_kind_of(Symbol) }
    assert_equal expected, err.message
  end


  def test__is_not_kind_of__error__multiple
    expected = "`testee#1': should not be Symbol"
    err = assert_raises(error) { v(:foo).is_not_kind_of(Symbol, Hash, Array) }
    assert_equal expected, err.message
  end


  #-------------------------------------
  # speaks
  #-------------------------------------


  def test__speaks__error
    expected = "`testee#1': should respond to method `bar'"
    err = assert_raises(error) { v(:foo).speaks(:bar) }
    assert_equal expected, err.message
  end


  def test__does_not_speak__error
    expected = "`testee#1': should not respond to method `to_s'"
    err = assert_raises(error) { v(:foo).does_not_speak(:to_s) }
    assert_equal expected, err.message
  end


  #-------------------------------------
  # asserts
  #-------------------------------------


  def test__asserts__error__without_block
    expected = "`testee#1': method `empty?' returned falsy value"
    err = assert_raises(error) { v(:foo).asserts(:empty?) }
    assert_equal expected, err.message
  end

  def test__asserts__error__with_block
    expected = "`testee#1': method `size' returned falsy value"
    err = assert_raises(error) { v(:foo).asserts(:size) { false } }
    assert_equal expected, err.message
  end

  def test__asserts__error__with_block_and_exception
    expected = "`testee#1': method `size' failed: ZeroDivisionError: divided by 0"
    err = assert_raises(error) { v(:foo).asserts(:size) { 1/0 } }
    assert_equal expected, err.message
  end

  def test__asserts_not__error__without_block
    expected = "`testee#1': method `size' returned truthy value"
    err = assert_raises(error) { v(:foo).asserts_not(:size) }
    assert_equal expected, err.message
  end

  def test__asserts_not__error__with_block
    expected = "`testee#1': method `empty?' returned truthy value"
    err = assert_raises(error) { v(:foo).asserts_not(:empty?) { true } }
    assert_equal expected, err.message
  end

  def test__assertsnot__error__with_block_and_exception
    expected = "`testee#1': method `empty?' failed: ZeroDivisionError: divided by 0"
    err = assert_raises(error) { v(:foo).asserts_not(:empty?) { 1/0 } }
    assert_equal expected, err.message
  end

end