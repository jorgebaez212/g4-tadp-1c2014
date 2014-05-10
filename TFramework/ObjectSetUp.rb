require_relative './Trait.rb'

class Object
  def create_method(name, &block)
    self.send(:define_method, name, &block)
  end

  def create_singleton_method(name, &block)
    self.send(:define_singleton_method, name, &block)
  end

  class Meth
    attr_accessor :type, :name, :block
  end

  def c_meth(name, &block)
    m = Meth.new
    m.name = name
    m.type = :class
    m.block = Proc.new(&block)
    return m
  end

  def i_meth(name, &block)
    m = Meth.new
    m.name = name
    m.type = :instance
    m.block = Proc.new(&block)
    return m
  end

  def uses (*traits)
    traits.each{ |trait|
      a = Trait.trait_list_instance[trait]
      a.each { |key,value| create_method(key, &value)}
      a = Trait.trait_list_class[trait]
      a.each { |key,value| create_singleton_method(key, &value)}
    }
  end

end