require_relative './Trait.rb'


class ConflicException < Exception; end

class Symbol

  def +(trait_name)
    name = (self.to_s+'_'+trait_name.to_s).to_sym
    copyToTrait name, self, ""
    copyToTrait name, trait_name, self
    name
  end

  def - (list)
    #El nombre de un trait generado por una expresion de tipo   class Clase
    #                                                             uses :T1 - [:m1,:m2]
    #                                                             ...
    #                                                           end
    #Sera :T1_sin-m1_sin-m2
    name=self.to_s
    fnNombreMetodosQuitados=Proc.new do|simbolo|name=name+'_sin-'+simbolo.to_s end
    list.each { |metodoAQuitar| fnNombreMetodosQuitados.call(metodoAQuitar) }
    name=name.to_sym

    #Se copian los metodos del trait original
    copyToTrait name, self, []

    #Se sacan los que se quería excluir
    list.each { |metodoAQuitar|
      if(Trait.trait_list_instance[name].has_key? metodoAQuitar)
        Trait.remove_instance_method name, metodoAQuitar
      else
        Trait.remove_class_method name, metodoAQuitar
      end  }

    #Devuelvo el symbol del trait especial (sin los metodos indicados en la lista)
    name
  end

  def copyToTrait(trait_nuevo, trait_viejo1, trait_viejo2)
    Trait.define (trait_nuevo){}

    Trait.trait_list_instance[trait_viejo1].each do |nombre_metodo,codigo|

      if(Trait.trait_list_instance[trait_nuevo].key?(nombre_metodo) )
        Trait.strategy_type.resolver_conflictos(trait_nuevo, trait_viejo1, trait_viejo2, nombre_metodo, &codigo)
      else
        Trait.define (trait_nuevo){ instance_method(nombre_metodo,&codigo)}
      end
    end

    Trait.trait_list_class[trait_viejo1].each do |key,value|
      if(Trait.trait_list_class[trait_nuevo].key?(key))

        #Trait.generate_new_method trait_viejo1, trait_nuevo, key, value
        if Trait.strategy_type == 1
          Trait.define (trait_nuevo){ class_method((key.to_s+'_'+trait_viejo1.to_s).to_sym,&value)}
        else
          Trait.define (trait_nuevo){
            class_method(key, &Proc.new {raise ConflicException.new(), 'Conflicto de metodos de clase llamados: "%s" en traits: "%s" y "%s"' % [key,trait_viejo1,trait_nuevo]})
          }
        end
      else
        Trait.define(trait_nuevo){class_method(key,&value)}
      end
    end
  end

  def class_alias_method(trait_name, method_name)
    value = Trait.remove_class_method trait_name, self.to_sym
    Trait.define(trait_name){class_method(method_name,&value)}
  end

  def instance_alias_method(trait_name, method_name)
    value = Trait.remove_instance_method trait_name, self.to_sym
    Trait.define(trait_name){instance_method(method_name,&value)}
  end

  #Creo metodo de clase con nombre nuevo
  def >(method_name)
    Proc.new do |trait_name|
      name = (self.to_s+'_c_'+method_name.to_s).to_sym
      copyToTrait name, trait_name, []
      class_alias_method name, method_name
    end
  end

  #Creo metodo de instancia con nombre nuevo
  def <(method_name)

    Proc.new do |trait_name|
      name = (trait_name.to_s+'_i_'+method_name.to_s).to_sym
      copyToTrait name, trait_name, []
      instance_alias_method name, method_name
      name
    end
  end

  def << (method)
    method.call self.to_sym
  end
end
