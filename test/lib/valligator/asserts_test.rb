require_relative '../../test_helper'


class TestAsserts < Minitest::Test
  include Valligator::Helper

  def error
    Valligator::ValidationError
  end


  positive_statements = [:asserts, :has, :is]
  negative_statements = [:asserts_not, :does_not_have, :is_not]


  positive_statements.each do |method|
    define_method 'test_that__%s__returns_an_instance_of_valligator' % method do
      assert_instance_of Valligator, v(:a).send(method, :size)
    end


    define_method 'test_that__%s__passes_when_testee_returns_truthy_value' % method do
      v(:a).send(method, :to_s)
      v(:a).send(method, :[], 0)
      v(:a).send(method, :size){self == 1}
      v(:a).send(method, :to_s).send(method, :[], 0).send(method, :size){self == 1}
    end


    define_method 'test_that__%s__fails_when_testee_returns_falsy_value' % method do
      assert_raises(error) { v(:a).send(method, :empty?) }
      assert_raises(error) { v(:a).send(method, :[], 1) }
      assert_raises(error) { v(:a).send(method, :size){self != 1} }
      assert_raises(error) { v(:a).send(method, :to_s).send(method, :[], 0).send(method, :size){self != 1} }
    end
  end


  negative_statements.each do |method|
    define_method 'test_that__%s__returns_an_instance_of_valligator' % method do
      assert_instance_of Valligator, v(:a).send(method, :empty?)
    end


    define_method 'test_that__%s__passes_when_testee_returns_falsy_value' % method do
      v(:a).send(method, :empty?)
      v(:a).send(method, :[], 1)
      v(:a).send(method, :size){self != 1}
      v(:a).send(method, :empty?).send(method, :[], 1).send(method, :size){self != 1}
    end


    define_method 'test_that__%s__fails_when_testee_returns_truthy_value' % method do
      assert_raises(error) { v(:a).send(method, :to_s) }
      assert_raises(error) { v(:a).send(method, :[], 0) }
      assert_raises(error) { v(:a).send(method, :size){self == 1} }
      assert_raises(error) { v(:a).send(method, :empty?).send(method, :[], 1).send(method, :size){self == 1} }
    end
  end
end