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