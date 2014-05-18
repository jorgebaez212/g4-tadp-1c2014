require_relative './Trait.rb'
class Object

  attr_accessor :strategyType, :function

  def create_method(method_name, &block)
    self.send(:define_method, method_name, &block)
  end

  def create_singleton_method(method_name, &block)
    self.send(:define_singleton_method, method_name, &block)
  end

  def strategy(strategy_type)
    Trait.strategy_type=strategy_type
  end

  def strategy_with_function(strategyType, &function)
    Trait.strategy_type=strategyType
    Trait.function = Proc.new &function
  end

  def uses (*traits)
    traits.each{ |trait|

      Trait.trait_list_instance[trait].each do |metodo,codigo|
          create_method(metodo, &codigo)
      end

      Trait.trait_list_class[trait].each do |metodo,codigo|
          create_singleton_method(metodo, &codigo)
      end
    }
  end


end