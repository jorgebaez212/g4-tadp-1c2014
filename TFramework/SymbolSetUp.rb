require_relative './Trait.rb'

class Symbol
  def +(other)
    name = (self.to_s+'_'+other.to_s).to_sym

    copyToTrait name, self
    copyToTrait name, other

    name
  end

  def copyToTrait(tNew, tOld)
    Trait.trait_list_instance[tOld].each do |key,value|
      Trait.define tNew, i_meth(key,&value)
    end
    Trait.trait_list_class[tOld].each do |key,value|
      Trait.define tNew, c_meth(key,&value)
    end
  end

  def c_aliasMethod(traitName, newMethodName)
    value = Trait.c_removeMethod traitName, self.to_sym
    Trait.define traitName, c_meth(newMethodName,&value)
  end

  def i_aliasMethod(traitName, newMethodName)
    value = Trait.i_removeMethod traitName, self.to_sym
    Trait.define traitName, i_meth(newMethodName,&value)
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