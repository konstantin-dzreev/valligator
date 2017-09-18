require_relative '../../test_helper'


class TestErrors < Minitest::Test
  include Valligator::Helper


  def error
    Valligator::ValidationError
  end


  def test_without_testee_name
    expected = "at `testee#1.speaks'"
    err = assert_raises(error) { v(:foo).speaks(:foo) }
    assert_equal expected, err.message
  end


  def test_with_testee_name
    expected = "at `i-have-a-name.speaks'"
    err = assert_raises(error) { v(:foo, names: 'i-have-a-name').speaks(:foo) }
    assert_equal expected, err.message
  end


  def test_long_path
    expected = "at `testee#1.speaks.asserts_not.has.is_instance_of.speaks'"
    err = assert_raises(error) do |variable|
      v(:foo).speaks(:to_s).\
              asserts_not(:empty?).\
              has(:size){self > 1}.\
              is_instance_of(Symbol).\
              speaks(:it_dies_here).\
              asserts(:thould_not_reach_this)
    end
    assert_equal expected, err.message
  end

end