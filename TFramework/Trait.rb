require_relative './Estrategias.rb'

class Trait
  class << self
    attr_accessor :trait_list_instance, :trait_list_class, :tmp_trait, :strategy, :strategy_type
  end

  Trait.trait_list_instance = Hash.new {|hash,trait| hash[trait] = Hash.new}
  Trait.trait_list_class = Hash.new {|hash,trait| hash[trait] = Hash.new}
  Trait.strategy_type = EstrategiaPorDefault.new

  def self.class_method(method_name, &block)
    trait_list_class[tmp_trait][method_name] = Proc.new(&block)
  end

  def self.instance_method(method_name, &block)
    trait_list_instance[tmp_trait][method_name] = Proc.new(&block)
  end


  def self.define(trait_name, &block)
    self.tmp_trait = trait_name
    self.instance_eval &block
  end

  def self.remove_class_method(trait_name, method_name)
    list = trait_list_class[trait_name]
    #Eliminar de lista
    method = list[method_name]
    list.delete method_name
    method
  end

  def self.remove_instance_method(trait_name, method_name)
    list = trait_list_instance[trait_name]
    #Eliminar de lista
    method = list[method_name]
    list.delete method_name
    method
  end
end