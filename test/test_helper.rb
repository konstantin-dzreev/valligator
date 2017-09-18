require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/valligator'

Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new({ color: true })]