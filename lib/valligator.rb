require_relative 'valligator_helper'

class Valligator
  Error            = Class.new(StandardError)
  ValidationError = Class.new(Error)

  INFINITY = 1/0.0

  attr_reader :testees
  attr_reader :names
  attr_reader :stack


  # Creates a new Valligator instance
  #
  # @param [Array<Object>] testees  One or more objects to be tested
  # @param option [Array<String>] :names  Testee names
  # @return [Valligator]
  #
  # @example
  #   # validate that testee is an instance of String
  #   Valligator.new('foo').is_instance_of(String) #=> OK
  #
  # @example
  #   # validate that all testees respond to :to_s and :upcase methods
  #   Valligator.new('foo', 'bar', :baz).speaks(:to_s, :upcase) #=> OK
  #
  # @example
  #   # validate that all testees have size == 3 and start with 'b' and they are Strings
  #   testees = ['boo', 'bar', :baz]
  #   Valligator.new(*testees).has(:size){self == 3}.has(:[], 0){self == 'b'}.is_instance_of(String)
  #     #=> Valligator::ValidationError: at `testee#3.has.has.is_instance_of'
  #
  # @example
  #   # validate that all hash values are Integers <= 2
  #   h = { foo: 1, bar: 2, baz: 3 }
  #   Valligator.new(*h.values, names: h.keys).is_instance_of(Integer).asserts(:<= , 2)
  #     #=> Valligator::ValidationError: at `baz.is_instance_of.asserts'
  #
  def initialize(*testees, names: nil)
    @testees = testees
    @names   = Array(names)
    @stack   = []
  end


  # @private
  def method_missing(method, *args, &block)
    case
    when method[/^does_not_speak_(.+)?$/] then does_not_speak(*args.unshift($1.to_sym))
    when method[/^speaks_(.+)?$/ ]        then speaks(*args.unshift($1.to_sym))
    when method[/^asserts_not_(.+)?$/]    then asserts_not($1.to_sym, *args, &block)
    when method[/^asserts_(.+)?$/]        then asserts($1.to_sym, *args, &block)
    when method[/^does_not_have_(.+)?$/]  then does_not_have($1.to_sym, *args, &block)
    when method[/^has_(.+)?$/]            then has($1.to_sym, *args, &block)
    when method[/^is_not_(.+)?$/]         then is_not($1.to_sym, *args, &block)
    when method[/^is_(.+)?$/]             then is($1.to_sym, *args, &block)
    else super(method, *args, &block)
    end
  end


  # Passes when the testee is an instance of either of the classes
  #
  # @param [Array<Class>] classes
  # @return [Valligator]
  # @raise [Valligator::ValidationError]
  #
  # @example
  #   Valligator.new('foo').is_instance_of(Integer, String) #=> OK
  #   Valligator.new('foo').is_instance_of(Integer, Array)  #=> Valligator::ValidationError
  #
  def is_instance_of(*classes)
    clone._is_instance_of(__method__, *classes)
  end


  # Passes when the testee is not an instance of all of the classes
  #
  # @param [Array<Class>] classes
  # @return [Valligator]
  # @raise [Valligator::ValidationError]
  #
  # @example
  #   Valligator.new('foo').is_not_instance_of(Integer, String) #=> Valligator::ValidationError
  #   Valligator.new('foo').is_not_instance_of(Integer, Array) #=> OK
  #
  def is_not_instance_of(*classes)
    clone._is_instance_of(__method__, *classes)
  end


  # Passes when the testee responds to all the methods
  #
  # @param [Array<Symbols>] methods
  # @return [Valligator]
  # @raise [Valligator::ValidationError]
  #
  # @example
  #   Valligator.new('foo').speaks(:size, :empty?) #=> OK
  #   Valligator.new('foo').speaks(:size, :foo)    #=> Valligator::ValidationError
  #
  def speaks(*methods)
    clone._speaks(__method__, *methods)
  end


  # Passes when the testee does not respond to all the methods
  #
  # @param [Array<Symbols>] methods
  # @return [Valligator]
  # @raise [Valligator::ValidationError]
  #
  # @example
  #   Valligator.new('foo').does_not_speak(:foo, :boo)  #=> OK
  #   Valligator.new('foo').does_not_speak(:foo, :size) #=> Valligator::ValidationError
  #
  def does_not_speak(*methods)
    clone._speaks(__method__, *methods)
  end


  # When no block given it passes if the testee, called with a given method and arguments, returns truthy value.
  #
  # When block is given then it calls the testee with the given method and arguments.
  # Then it calls the block in the context of the value returned above, and if the block returns truthy value the
  # validation passes.
  #
  # P.S. Truthy value is anything but nil or false.
  #
  # @param [Symbol] method
  # @param [Array<Object>] args
  # @yield [Object]
  # @raise [Valligator::ValidationError]
  #
  # @example
  #   Valligator.new('foo').asserts(:size)                #=> OK
  #   Valligator.new('foo').asserts(:[], 0)               #=> OK
  #   Valligator.new('foo').asserts(:[], 0) {self == 'f'} #=> OK
  #   Valligator.new('foo').asserts(:empty?)              #=> Valligator::ValidationError
  #   Valligator.new('foo').asserts(:[], 100)             #=> Valligator::ValidationError
  #   Valligator.new('foo').asserts(:[], 0) {self == 'F'} #=> Valligator::ValidationError
  #
  # @see #is
  # @see #has
  #
  def asserts(method, *args, &block)
    clone._asserts(__method__, method, *args, &block)
  end


  # When no block given it passes if the testee, called with a given method and arguments, returns falsy value.
  #
  # When block is given then it calls the testee with the given method and arguments.
  # Then it calls the block in the context of the value returned above, and if the block returns falsy value the
  # validation passes.
  #
  # P.S. Falsy value is either nil or false.
  #
  # @param [Symbol] method
  # @param [Array<Object>] args
  # @yield [Object]
  # @raise [Valligator::ValidationError]
  #
  # @example
  #   Valligator.new('foo').asserts_not(:size)                #=> Valligator::ValidationError
  #   Valligator.new('foo').asserts_not(:[], 0)               #=> Valligator::ValidationError
  #   Valligator.new('foo').asserts_not(:[], 0) {self == 'f'} #=> Valligator::ValidationError
  #   Valligator.new('foo').asserts_not(:empty?)              #=> OK
  #   Valligator.new('foo').asserts_not(:[], 100)             #=> OK
  #   Valligator.new('foo').asserts_not(:[], 0) {self == 'F'} #=> OK
  #
  # @see #is_not
  # @see #does_not_have
  #
  def asserts_not(method, *args, &block)
    clone._asserts(__method__, method, *args, &block)
  end


  # Is an alias for {#asserts} method
  #
  def is(method, *args, &block)
    clone._asserts(__method__, method, *args, &block)
  end


  # Is an alias for {#asserts_not} method
  #
  def is_not(method, *args, &block)
    clone._asserts(__method__, method, *args, &block)
  end


  # Is an alias for {#asserts} method
  #
  def has(method, *args, &block)
    clone._asserts(__method__, method, *args, &block)
  end


  # Is an alias for {#asserts_not} method
  #
  def does_not_have(method, *args, &block)
    clone._asserts(__method__, method, *args, &block)
  end


  protected


  # Returns testee name by its index
  #
  # @param [Integer] idx
  # @return [String]
  #
  def name_by_idx(idx)
    @names && @names[idx] || ('testee#%d' % (idx+1))
  end


  # Adds method to the stack of the tested ones
  #
  # @param [Symbol] method_name
  # @return [void]
  #
  def push(method_name)
    @stack << method_name
  end


  # Raises requested exception
  #
  # @param [Class] exception
  # @param option [Integer] idx  Testee index
  # @param option [nil,String] msg Error explanation (when required)
  #
  def error(exception, idx=0, msg=nil)
    msg += ' ' if msg
    raise(exception, "%sat `%s.%s'" % [msg, name_by_idx(idx), @stack.join('.')])
  end


  # Calls the given block for each testee and each item from the list.
  #
  # @param optional list [Array]
  #
  # @yield [testee, idx, list_item]
  # @yieldparam testee [Object]
  # @yieldparam idx [Integer] testee index
  # @yieldparam optional list_item [Integer] when list is given
  #
  # @return [void]
  #
  def each(*list)
    list << nil if list.empty?
    @testees.each_with_index do |testee, idx|
      list.each do |list_item|
        yield(testee, idx, list_item)
      end
    end
  end


  # Clones current instance.
  #
  # @return [Valligator]
  #
  def clone
    self.class.new(*@testees, names: @names).tap do |v|
      v.stack.push(*stack)
    end
  end


  #------------------------------------------
  # Validations
  #------------------------------------------


  # Validates number of arguments
  #
  # @param [Array<Object>] args
  # @param [Integer] expected
  # @return [void]
  # @raise [ArgumentError]
  #
  def validate_number_of_arguments(args, expected)
    return if expected === args.size

    expected == expected.first if expected.is_a?(Range) && expected.size == 1
    error(ArgumentError, 0, 'wrong number of arguments (%s for %s)' % [args.size, expected])
  end


  # Validates argument type
  #
  # @param [Array<Class>] classes
  # @param [Array<Object>] args
  # @param [Integer] arg_idx
  # @return [void]
  # @raise [ArgumentError]
  #
  def validate_argument_type(classes, arg, arg_idx)
    return if classes.any? { |klass| arg.is_a?(klass) }
    classes = classes.map { |klass| klass.inspect }.join(' or ')
    error(ArgumentError, 0, 'wrong argument type (arg#%d is a %s instead of %s)' % [arg_idx, arg.class.name, classes])
  end


  # Validates if object responds to a method
  #
  # @param [Object] object
  # @param [Array<Object>] args
  # @param [Integer] idx
  # @return [void]
  # @raise [ArgumentError]
  #
  def validate_respond_to(object, method, idx)
    return if object.respond_to?(method)
    str = object.to_s
    str = str[0..-1] + '...' if str.size > 20
    error(NoMethodError, idx, 'undefined method `%s\' for %s:%s' % [method, str, object.class.name])
  end


  #------------------------------------------
  # Statements
  #------------------------------------------


  # @private
  # @see #is_instance_of
  #
  def _is_instance_of(statement, *classes)
    push(statement)
    equality = !statement[/not/]

    matches = [false] * @testees.count

    validate_number_of_arguments(classes, 1..INFINITY)
    classes.each_with_index { |klass, idx| validate_argument_type([Class], klass, idx+1) }

    each(*classes)          { |testee, idx, klass|  matches[idx] = true if testee.is_a?(klass) }
    matches.each_with_index { |match, idx| error(ValidationError, idx) if matches[idx] != equality }
    self
  end


  # @private
  # @see #speaks
  #
  def _speaks(statement, *methods)
    push(statement)
    equality = !statement[/not/]

    validate_number_of_arguments(methods, 1..INFINITY)

    methods.each_with_index do |arg, idx|
      validate_argument_type([Symbol], arg, idx+1)
    end

    each(*methods) do |testee, idx, method|
      next if testee.respond_to?(method) == equality

      error(ValidationError, idx)
    end
    self
  end


  # @private
  # @see #speaks
  #
  def _asserts(statement, method, *args, &block)
    push(statement)
    equality = !statement[/not/]

    each do |testee, idx|
      validate_respond_to(testee, method, idx)
      response = testee.__send__(method, *args)
      begin
        # Execute block in the context on the response so that one could retrieve it using self keyword.
        response = response.instance_eval(&block) if block
      rescue
        # This error will have 'cause' set to the original exception raised in the block
        error(ValidationError, idx)
      end
      error(ValidationError, idx) if !!response != equality
    end
    self
  end
end