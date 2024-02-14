#### 1.0.6
  - It should work fine with ruby 3

#### 1.0.5
  - Do not use minitest/reporters

#### 1.0.4
  - Valligator::ValidationError.validation_stack returns the exact position in validation method chain where the validation fails
  - **is_kind_of** got a new alias **is_an**
  - **is_not_kind_of** got a new alias **is_not_an**
  - all alias methods were replaced with ruby's built-in **alias_method**, so error messages will refer to the original  method name:
      Example:
        123.is_a(String)
        # old behavior
        Valligator::ValidationError: wrong number of arguments (0 for 1..Infinity) at `testee#1.is_a
        # new behavior
        Valligator::ValidationError: wrong number of arguments (0 for 1..Infinity) at `testee#1.is_kind_of

#### 1.0.3
  - **is_instance_of** renamed to **is_kind_of**
  - **is_not_instance_of** renamed to **is_not_kind_of**
  - new helper method: Valligator::Helper#vh(Hash)

#### 1.0.2
  - **is_instance_of** got a new alias **is_a**
  - **is_not_instance_of** got a new alias **is_not_a**

#### 1.0.1
  - couple bug fixes