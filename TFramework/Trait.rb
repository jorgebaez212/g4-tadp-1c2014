class Trait
  class << self
    attr_accessor :trait_list_instance, :trait_list_class, :tmpTrait
  end

  Trait.trait_list_instance = Hash.new
  Trait.trait_list_class = Hash.new

  def self.c_meth(methodName, &block)
    trait_list_class[tmpTrait][methodName] = Proc.new(&block)
  end

  def self.i_meth(methodName, &block)
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

  def self.c_removeMethod(traitName, methodName)
    list = trait_list_class[traitName]
    #Eliminar de lista
    method = list[methodName]
    list.delete methodName
    method
  end

  def self.i_removeMethod(traitName, methodName)
    list = trait_list_instance[traitName]
    #Eliminar de lista
    method = list[methodName]
    list.delete methodName
    method
  end
end