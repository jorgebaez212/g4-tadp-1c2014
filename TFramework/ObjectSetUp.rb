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

      checkConflicts(self, trait)

      a = Trait.trait_list_instance[trait]
      a.each { |key,value| create_method(key, &value)}
      a = Trait.trait_list_class[trait]
      a.each { |key,value| create_singleton_method(key, &value)}
    }
  end

  def checkConflicts(currentClass, trait)
    currentClass.instance_methods.each do |key|
      if(Trait.trait_list_instance[trait].key?(key))
        raise ConflicException.new(), 'Conflicto de metodos de instancia llamados: "%s" en traits: "%s" y "%s"' % [key,trait,currentClass]
      end
    end
    currentClass.class.public_methods.each do |key|
      if(Trait.trait_list_class[trait].key?(key))
        raise ConflicException.new(), 'Conflicto de metodos de clase llamados: "%s" en Trait: "%s" y Clase: "%s"' % [key,trait,currentClass]
      end
    end
  end

end