require_relative './Trait.rb'
class Object
  def create_method(name, &block)
    self.send(:define_method, name, &block)
  end

  def create_singleton_method(name, &block)
    self.send(:define_singleton_method, name, &block)
  end

  def uses (*traits)
    traits.each{ |trait|

      Trait.trait_list_instance[trait].each do |key,value|
          create_method(key, &value)
      end

      Trait.trait_list_class[trait].each do |key,value|
          create_singleton_method(key, &value)
      end
    }
  end
end