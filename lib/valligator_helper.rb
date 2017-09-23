class Valligator
  module Helper

    # Returns a new Valligator instance
    #
    # @param [Array<Object>] testees  One or more objects to be tested
    # @param option [Array<String>] :names  Testee names
    # @return [Valligator]
    #
    def valligate(*testees, names: nil)
      Valligator.new(*testees, names: names)
    end
    alias_method :v, :valligate


    # Returns a new Valligator instance created from a hash, where hash values are testees and hash keys are their names.
    #
    # @param [Hash] hash
    # @return [Valligator]
    #
    def vh(hash)
      Valligator.new(*hash.values, names: hash.keys)
    end

  end
end