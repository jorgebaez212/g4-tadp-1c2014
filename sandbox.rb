require 'rspec'

class Trait
  class << self
    attr_accessor :trait_list_instance, :trait_list_class
  end

  Trait.trait_list_instance = Hash.new
  Trait.trait_list_class = Hash.new

  def self.define(name, *args)
    #Si no existe una entrada en el Hash la creo
    if(trait_list_instance[name].nil?)
      trait_list_instance[name] = Hash.new
    end

    if(trait_list_class[name].nil?)
      trait_list_class[name] = Hash.new
    end

    args.each {|i|
      if(i.type==:instance)
        trait_list_instance[name][i.name] = i.block
      else
        trait_list_class[name][i.name] = i.block
      end
    }
  end

end



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

describe 'Test crea metodos' do
  before :all do
    Trait.define :T,
                 c_meth(:printHi) {puts 'Hola, mi nombre de metodo de clase es printHi'},
                 i_meth(:printHi2) {puts 'Hola, mi nombre de metodo de instancia es printHi2'}

    Trait.define :T2,
                 c_meth(:printHi3) {puts 'Hola, mi nombre de metodo de clase es printHi3'},
                 i_meth(:printHi4) {puts 'Hola, mi nombre de metodo de instancia es printHi4'}
  end
  it 'agrega metodo simple' do
    class Prueba
      uses :T, :T2
    end

    p = Prueba.new

    Prueba.should respond_to(:printHi)
    Prueba.should_not respond_to(:printHi2)
    p.should respond_to(:printHi2)
    p.should_not respond_to(:printHi)
  end
end