require_relative '../../test_helper'


class TestMethodMissing < Minitest::Test
  include Valligator::Helper


  def error
    Valligator::ValidationError
  end


  def test__speaks_something
    v(:foo).speaks_to_s
    assert_raises(error) { v(:foo).speaks_to_i }
  end


  def test__does_not_speak_something
    v(:foo).does_not_speak_to_i
    assert_raises(error) { v(:foo).does_not_speak_to_s }
  end


  [:asserts, :is, :has].each do |method|
    define_method 'test__%s_something' % method do
      m1 = '%s_to_s' % method
      m2 = '%s_empty?' % method
      v(:foo).send(m1)
      assert_raises(error) { v(:foo).send(m2) }
    end
  end


  [:asserts_not, :is_not, :does_not_have].each do |method|
    define_method 'test__%s_something' % method do
      m1 = '%s_empty?' % method
      m2 = '%s_to_s'   % method
      v(:foo).send(m1)
      assert_raises(error) { v(:foo).send(m2) }
    end
  end
end