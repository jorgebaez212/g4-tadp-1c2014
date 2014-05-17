require_relative './Trait.rb'


class ConflicException < Exception; end

class Symbol

  def +(other)
    #Verificacion de conflictos

    name = (self.to_s+'_'+other.to_s).to_sym

    copyToTrait name, self, ""
    copyToTrait name, other, self




    #agregar_llamada_a_todos self, other, name, metodos_con_conflictos
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

  #Trait.define (trait_nuevo){ i_meth(key.to_s +'_' +trait_viejo1.to_s,&value)}

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

  def c_aliasMethod(traitName, newMethodName)
    value = Trait.remove_class_method traitName, self.to_sym
    Trait.define(traitName){class_method(newMethodName,&value)}
  end

  def i_aliasMethod(traitName, newMethodName)
    value = Trait.remove_instance_method traitName, self.to_sym
    Trait.define(traitName){instance_method(newMethodName,&value)}
  end

  #Creo metodo de clase con nombre nuevo
  def >(newMethodName)
    Proc.new do |traitName|
      name = (self.to_s+'_c_'+newMethodName.to_s).to_sym
      copyToTrait name, traitName, []
      c_aliasMethod name, newMethodName
    end
  end

  #Creo metodo de instancia con nombre nuevo
  def <(newMethodName)

    Proc.new do |traitName|
      name = (traitName.to_s+'_i_'+newMethodName.to_s).to_sym
      copyToTrait name, traitName, []
      i_aliasMethod name, newMethodName
      name
    end
  end

  def << (method)
    method.call self.to_sym
  end

  def checkConflicts(unTrait,other)

    metodos_con_conflictos = Array.new
    Trait.trait_list_instance[unTrait].each {|key, value|
      Trait.trait_list_instance[unTrait].each {|key2,value2|
          metodos_con_conflictos.push key if key == key2
      }
    }
    metodos_con_conflictos
  end

end
