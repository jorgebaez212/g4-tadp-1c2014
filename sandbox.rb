require 'rspec'

class Trait
  class << self
    attr_accessor :trait_list
  end

  Trait.trait_list = Array.new

  def self.define(name, methodName, &method)
    trait_list.push(InnerTrait.new(name, methodName, &method))
  end

  def self.define2(*args)
    args.each{
        |a|
        method = a.method
        trait_list.push(InnerTrait.new(a.name, method.to_s, &method))
    }


  end

  class InnerTrait
    attr_accessor :name, :method, :methodName

    def initialize(name, methodName, &method)
      self.name=name
      self.method=method
      self.methodName=methodName
    end

  end
end



class Object
  def create_method(name, &block)
    self.send(:define_method, name, &block)
  end

  def create_singleton_method(name, &block)
    self.send(:define_singleton_method, name, &block)
  end

  def uses (trait)
    #include trait
    #Copiar solo los metodos, nada de variables de estado.

    #puts 'Agregando metodos para Trait: '+trait.to_s
    #puts 'Tiene metodo de clase printHi '+ (trait.singleton_methods(false).any? { |m| m.to_s=='printHi'}).to_s
    #puts 'Tiene metodo de instancia printHi2 '+(trait.instance_methods(false).any? { |m| m.to_s=='printHi2'}).to_s

    #self.send(:define_method, 'printHi2', &trait.instance_method(:printHi2)) #wrong argument type UnboundMethod (expected Proc) (TypeError)
    #trait.instance_method(:printHi2).bind(self) #`bind': bind argument must be an instance of TT (TypeError)

    #trait.instance_methods(false).each { |m| create_method(m.to_s, &m) }
    #trait.singleton_methods.each { |m| create_singleton_method(m.to_s, &m) }

    #puts 'Soy '+self.to_s+' se me agregaron los sig metodos'
    #puts 'De Clase'
    #puts self.singleton_methods(false)
    #puts 'De instancia'
    #puts self.instance_methods(false)


    a = Trait.trait_list.detect{ |e| e.name==trait }
    m = a.method
    self.send(:define_method, m.to_s, &m)

  end
end

class Module
  def+ (obj)
    m=Module.new do
      include obj
      include self
    end
    m
  end
end

Trait.define2 do
  name :'T'
  method :'printHi' do
    puts 'Hola, mi nombre de funcion es printHi2'
  end
end

Trait.define('TT', 'printHi2') {puts 'Hola, mi nombre de funcion es printHi2'}

class Prueba
  #uses T
  #uses TT
  uses 'T'
  uses 'TT'

  #create_method ('printHi') {puts 'hello there'}
end


class Lala
  #puts Prueba.private_methods
  #puts Prueba.public_methods
  #puts Prueba.singleton_methods
  p = Prueba.new

  #puts '__Prueba.public_methods__'
  #Prueba.public_methods(false).each{|a| puts a}
  #puts '__Prueba.singleton_method__'
  #Prueba.singleton_methods(false).each{|a| puts a}
  #puts '__p.public_methods__'
  #p.public_methods(false).each{|a| puts a}
  #puts '__p.singleton_method__'
  #p.singleton_methods(false).each{|a| puts a}
  #Prueba.singleton_methods(false).each{|a| puts a}
  #p.printHi
  p.printHi
  #Prueba.printHi2
end

