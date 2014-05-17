require_relative './Trait.rb'


class ConflicException < Exception; end

class Symbol



  def +(other)
    #Verificacion de conflictos
    checkConflicts(self,other)

    name = (self.to_s+'_'+other.to_s).to_sym

    copyToTrait name, self
    copyToTrait name, other

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
    copyToTrait name, self

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

  def copyToTrait(tNew, tOld)
    Trait.trait_list_instance[tOld].each do |key,value|
      Trait.define (tNew){i_meth(key,&value)}
    end
    Trait.trait_list_class[tOld].each do |key,value|
      Trait.define(tNew){c_meth(key,&value)}
    end
  end

  def checkConflicts(tNew, tOld)
    Trait.trait_list_instance[tNew].each do |key,value|
      if(Trait.trait_list_instance[tOld].key?(key))
        raise ConflicException.new(), 'Conflicto de metodos de instancia llamados: "%s" en traits: "%s" y "%s"' % [key,tOld,tNew]
      end
    end
    Trait.trait_list_class[tNew].each do |key,value|
      if(Trait.trait_list_class[tOld].key?(key))
        raise ConflicException.new(), 'Conflicto de metodos de clase llamados: "%s" en traits: "%s" y "%s"' % [key,tOld,tNew]
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
      copyToTrait name, traitName
      c_aliasMethod name, newMethodName
    end
  end

  #Creo metodo de instancia con nombre nuevo
  def <(newMethodName)

    Proc.new do |traitName|
      name = (traitName.to_s+'_i_'+newMethodName.to_s).to_sym
      copyToTrait name, traitName
      i_aliasMethod name, newMethodName
      name
    end
  end

  def << (method)
    method.call self.to_sym
  end

end