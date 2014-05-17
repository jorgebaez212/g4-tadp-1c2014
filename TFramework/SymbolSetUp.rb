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
        Trait.i_removeMethod name, metodoAQuitar
      else
        Trait.c_removeMethod name, metodoAQuitar
      end  }

    #Devuelvo el symbol del trait especial (sin los metodos indicados en la lista)
    name
  end

  #Trait.define (tNew){ i_meth(key.to_s +'_' +tOld.to_s,&value)}

  def copyToTrait(tNew, tOld, previousTrait)
    Trait.define (tNew){}

    Trait.trait_list_instance[tOld].each do |key,value|

      if(Trait.trait_list_instance[tNew].key?(key) )
        #Trait.generate_new_method tOld, tNew, key, value
        if Trait.strategyType == 1

          Trait.i_removeMethod tNew, key

          Trait.define (tNew){ i_meth((key.to_s+'_'+tOld.to_s).to_sym,&value)}
          Trait.define (tNew){ i_meth((key.to_s+'_'+previousTrait.to_s).to_sym, &Trait.trait_list_instance[previousTrait][key])}

          Trait.define (tNew){ i_meth(key) do
            self.send (key.to_s+'_'+previousTrait.to_s).to_sym;
            self.send (key.to_s+'_'+tOld.to_s).to_sym;
          end
          }
        else
          Trait.define (tNew){ i_meth(key, &Proc.new {
            raise ConflicException.new(), 'Conflicto de metodos de instancia llamados: "%s" en traits: "%s" y "%s"' % [key,tOld,tNew]} )
          }
        end
      else
        Trait.define (tNew){ i_meth(key,&value)}
      end
    end

    Trait.trait_list_class[tOld].each do |key,value|
      if(Trait.trait_list_class[tNew].key?(key))

        #Trait.generate_new_method tOld, tNew, key, value
        if Trait.strategyType == 1
          Trait.define (tNew){ c_meth((key.to_s+'_'+tOld.to_s).to_sym,&value)}
        else
          Trait.define (tNew){
            c_meth(key, &Proc.new {raise ConflicException.new(), 'Conflicto de metodos de clase llamados: "%s" en traits: "%s" y "%s"' % [key,tOld,tNew]})
          }
        end
      else
        Trait.define(tNew){c_meth(key,&value)}
      end
    end
  end

  def c_aliasMethod(traitName, newMethodName)
    value = Trait.c_removeMethod traitName, self.to_sym
    Trait.define(traitName){c_meth(newMethodName,&value)}
  end

  def i_aliasMethod(traitName, newMethodName)
    value = Trait.i_removeMethod traitName, self.to_sym
    Trait.define(traitName){i_meth(newMethodName,&value)}
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



