require_relative './Estrategias.rb'

class Trait
  class << self
    attr_accessor :trait_list_instance, :trait_list_class, :tmpTrait, :strategy, :strategy_type
  end



  Trait.trait_list_instance = Hash.new
  Trait.trait_list_class = Hash.new
  Trait.strategy_type = EstrategiaPorDefault.new

  def self.class_method(methodName, &block)
    trait_list_class[tmpTrait][methodName] = Proc.new(&block)
  end

  def self.instance_method(methodName, &block)
    trait_list_instance[tmpTrait][methodName] = Proc.new(&block)
  end


  def self.define(traitName, &block)
    #Si no existe una entrada en el Hash la creo
    if(trait_list_instance[traitName].nil?)
      trait_list_instance[traitName] = Hash.new
    end

    if(trait_list_class[traitName].nil?)
      trait_list_class[traitName] = Hash.new
    end

    self.tmpTrait = traitName
    self.instance_eval &block
  end

  def self.remove_class_method(traitName, methodName)
    list = trait_list_class[traitName]
    #Eliminar de lista
    method = list[methodName]
    list.delete methodName
    method
  end

  def self.remove_instance_method(traitName, methodName)
    list = trait_list_instance[traitName]
    #Eliminar de lista
    method = list[methodName]
    list.delete methodName
    method
  end
end