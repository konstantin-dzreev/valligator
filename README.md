# Valligator


## Ruby objects validator

In ruby we often run into a case when we need to validate method parameter types, check if their values are in the
required boundaries, or to perform any other crazy variable validations. The valligator an attempt to simplify the problem.


## Requirements

Ruby 2.0+


## Installation

Add it to your Gemfile

```
gem "valligator"
```

Or install manually:

```
gem install valligator
```

## Statements

There are 3 validations (a.k.a. statements) that the Valligator supports:

#### speaks

```
  testee.speaks(*methods)
  testee.does_not_speak(*methods)
```
  - _methods_ are symbols

The validations passes when testee responds to all (or none in negative case) the methods from the list.

#### is_instance_of
```
  testee.is_instance_of(*classes)
  testee.is_not_instance_of(*classes)
```
  - _classes_ a list of ruby classes

The validations passes when testee is an instance of any class (or not an instance of all the classes in negative case).

#### asserts
```
  testee.asserts(method, *method_args, &block)
  testee.asserts_not(method, *method_args, &block)
```
  - _method_ a method to be calld on testee
  - _method_args_ (optional) the method arguments
  - _block_ (optional) a block to be invoked in the context of the _method_ response

When the _block_ is not provided the validation passes if the _method_, called with _method_args_ on the testee, returns truthy response (not false or nil).

When the _block_ is provided the validation passes if the _block_, called in the context of the value returned by the _method_ called with _method_args_, returns truthy (not false or nil) value.

If it does not sound clear, then it is something like this:
```
  testee = Valligator.new(:foo)
  testee.has(:size){self == 10}

  # is the same as:

  value = :foo.size
  raise !!value.instance_eval { self == 10 }
```

I use _instance_eval_ so that the _value_ could be assessed as _self_, and one would not need to access it using standard block params definition ({|value| value == 10 }).

**asserts** has two aliases: **is** and **has**. The negative form **asserts_not** also has its own clones: **is_not**, **does_not_have**. All the methods are absolutely identical, just use what ever sounds more grammatically correct: _is(:active?)_, _has(:apples)_, _asserts(:respond_to?, :foo)_, etc.

## Method chaining

Each statement, if it does not fail, returns an instance of the Valligator, so that they can be chained:

```
  testee.is_instance_of(String).is_not(:empty?).has(:size){self > 10}.speaks(:to_s)
```

## Errors

When validation fails a Valligator::ValidationError is raised. The error message contains the full path of the
passed validations. If the validation above would fail on _is_instance_of_ statement the error message wold look like:

```
Valligator::ValidationError: at testee#1.is_instance_of
```

but if it would fail on _has_ then the erro would be


```
Valligator::ValidationError: at testee#1.is_instance_of.is_not.has
```

You can provide a testee name when you instantiate a Valligator instance, and the name will be used in the error message instead of 'testee#x'

```
testee = Valligator.new('Very long string', 'Short', names: ['long', 'short'])
testee.is_instance_of(String).has(:size){self > 10}
  #=> Valligator::ValidationError: at `short.is_instance_of.has'
```

## Examples

Validate that testee is an instance of String
```
Valligator.new('foo').is_instance_of(String) #=> OK
```

Validate that all testees respond to :to_s and :upcase methods
```
testees = ['foo', 'bar', :baz]
Valligator.new(*testees).speaks(:to_s, :upcase) #=> OK
```

Validate that all testees have size == 3 and start with 'b' and they are Strings
```
testees = ['boo', 'bar', :baz]
Valligator.new(*testees).has(:size){self == 3}.has(:[], 0){self == 'b'}.is_instance_of(String)
   #=> Valligator::ValidationError: at testee#3.has.has.is_instance_of'
```

Validate that all hash values are Integers <= 2
```
h = { foo: 1, bar: 2, baz: 3 }
Valligator.new(*h.values, names: h.keys).is_instance_of(Integer).asserts(:<= , 2)
  #=> Valligator::ValidationError: at `baz.is_instance_of.asserts'
```

## More examples

How about a completely synthetic example:

```
def charge!(payee, payment_gateway, order, currency, logger)
  # FIXME: I want validations before processing to the charge method
  charge(payee, payment_gateway, order, currency, logger)
end

```

And we would like to make sure that:

  * Payee:
    - is an instance of either a User or a RemoteSystem model
    - it is not blocked
    - it is a confirmed user
    - it has payment method registred
    - it can pay in a requested currency
  * Payment gateway:
    - is active
    - it can accept payment in the payment method that the user supports
  * Order
    - is not deleted
    - its status is set to :pending
    - its corresponding OrderItem records are not empty
  * OrderItems
    - are in the same currency that was passed with the method call
    - their price makes sence
  * Logger
    - is an IO object
    - it is not closed
    - the file it writes to is not '/dev/null'
  * Currency
    - equal to :usd

The most straightforward way to code this may look like the one below (yeah, Sandi Metz would hate it starting from the line # [6](https://robots.thoughtbot.com/sandi-metz-rules-for-developers)):

```
def charge!(payee, payment_gateway, order, currency, logger)
  if !(payee.is_a?(User) || payee.is_a?(RemoteSystem)) || payee.blocked? || !payee.confirmed? || !payee.payment_method || !payee.can_pay_in?(currency)
    raise(ArgumentError, 'Payee is not either a User or a RemoteSystem or is blocked or is not confirmed, or does not have a payment method set')
  end
  if !payment_gateway.active? || !payment_gateway.respond_to?(payee.payment_method)
    raise(ArgumentError, 'Payment gateway cannot charge users or is not active')
  end
  if order.deleted? || order.status != :pending || order.order_items.empty?
    raise(ArgumentError, 'Order is deleted or is not in pending state or does not have any items in it')
  end
  order.order_items.each do |item|
    if item.currency != currency || item.price <= 0
      raise(ArgumentError, 'There are order items not in USD or with a negative price')
    end
  end
  if !logger.is_a?(IO) || logger.closed? || logger.path == '/dev/null'
    raise(ArgumentError, 'Logger is not an IO instance or closed or writes to nowhere')
  end
  if currency != :usd
    raise(ArgumentError, 'Currency is expected to be set to USD')
  end

  charge(payee, payment_gateway, order, currency, logger)
end
```

Using the Valligator we can write all above as:

```
require 'valligator'

def charge!(payee, payment_gateway, order, currency, logger)
  Valligator.new(user).is_instance_of(User, RemoteSystem).is_not(:blocked?).is(:confirmed?).has(:payment_method).asserts(:can_pay_in?, currency)
  Valligator.new(payment_gateway).is(:active?).speaks(payee.payment_method)
  Valligator.new(order).is_not(:deleted?).has(:status) { self == :pending }.does_not_have(:order_items) { empty? }
  Valligator.new(*order.items).has(:currency){ self == currency }.has(:price) { self > 0 }
  Valligator.new(logger).is_instance_of(IO).is_not(:closed?).has(:path) { self != 'dev/null'}
  Valligator.new(currency).asserts(:==, :usd)

  charge(payee, payment_gateway, order, currency, logger)
end
```

or a little bit shorter using a handy _v_ method, provided by _Valligator::Helper_, and a more natural way of
writing statements:

```
require 'valligator'
include Valligator::Helper

def charge!(payee, payment_gateway, order, logger, currency)
  v(user).is_instance_of(User, RemoteSystem).is_not_blocked?.is_confirmed?.has_payment_method.asserts_can_pay_in?(currency)
  v(payment_gateway).is_active?.speaks(payee.payment_method)
  v(order).is_not_deleted?.has_status{ self == :pending }.does_not_have_order_items { empty? }
  v(*order.items).has_currency{ self == :usd }.has_price { self > 0 }
  v(logger).is_instance_of(IO).is_not_closed?.has_path { self != 'dev/null'}
  v(currency).asserts(:==, :usd)

  charge(payee, payment_gateway, order, currency, logger)
end
```

## Tests

```
rake test
```

## License

[MIT](https://opensource.org/licenses/mit-license.php) <br/>


## Author

Konstantin Dzreev, [konstantin-dzreev](https://github.com/konstantin-dzreev)
