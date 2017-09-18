class Valligator
  module Helper

    def valligate(*testees, names: nil)
      Valligator.new(*testees, names: names)
    end


    alias_method :v, :valligate

  end
end