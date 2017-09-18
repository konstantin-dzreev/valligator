require_relative '../../test_helper'


class TestIsInstanceOf < Minitest::Test
  include Valligator::Helper

  def error
    Valligator::ValidationError
  end

  positive_statements = [:is_instance_of, :is_a]
  negative_statements = [:is_not_instance_of, :is_not_a]
  all_statements = positive_statements + negative_statements

  all_statements.each do |method|
    define_method 'test_that__%s__fails_on_wrong_number_of_arguments' % method do
      expected = "wrong number of arguments (0 for 1..Infinity) at `testee#1.%s'" % method
      err = assert_raises(ArgumentError) { v(:a).send(method) }
      assert_equal expected, err.message
    end


    define_method 'test_that__%s__fails_on_wrong_argument_type' % method do
      expected = "wrong argument type (arg#1 is a NilClass instead of Class) at `testee#1.%s'" % method
      err = assert_raises(ArgumentError) { v(:a).send(method, nil) }
      assert_equal expected, err.message
    end
  end


  positive_statements.each do |method|
    define_method 'test_that__%s__returns_an_instance_of_valligator' % method do
      assert_instance_of Valligator, v(:a).send(method, Symbol)
    end


    define_method 'test_that__%s__passes_when_there_is_a_match' % method do
      v(:a).send(method, Symbol)
      v(:a).send(method, String, Symbol)
      v(:a).send(method, Symbol).send(method, Symbol)
    end


    define_method 'test_that__%s__fails_when_there_is_no_match' % method do
      assert_raises(error) { v(:a).send(method, String) }
      assert_raises(error) { v(:a).send(method, String, Integer) }
      assert_raises(error) { v(:a).send(method, Symbol).send(method, String) }
    end
  end


  negative_statements.each do |method|
    define_method 'test_that__%s__returns_an_instance_of_valligator' % method do
      assert_instance_of Valligator, v(:a).send(method, String)
    end


    define_method 'test_that__%s__passes_when_there_is_no_match' % method do
      v(:a).send(method, String)
      v(:a).send(method, String, Integer)
      v(:a).send(method, String).send(method, NilClass)
    end


    define_method 'test_that__%s__fails_when_there_is_a_match' % method do
      assert_raises(error) { v(:a).send(method, Symbol) }
      assert_raises(error) { v(:a).send(method, String, Symbol) }
      assert_raises(error) { v(:a).send(method, String).send(method, Symbol) }
    end
  end

end