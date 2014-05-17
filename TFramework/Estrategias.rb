class EstrategiaPorDefault
  def resolver_conflictos(trait_nuevo, trait_viejo1, trait_viejo2, nombre_metodo, &codigo_trait_viejo1)
    Trait.define (trait_nuevo){ instance_method(nombre_metodo, &Proc.new {
      raise ConflicException.new(), 'Conflicto de metodos de instancia llamados: "%s" en traits: "%s" y "%s"' % [nombre_metodo,trait_viejo1,trait_nuevo]} )
    }
  end
end

class EstrategiaLLamarATodos

  def resolver_conflictos(trait_nuevo, trait_viejo1, trait_viejo2, nombre_metodo, &codigo_trait_viejo1)
    Trait.remove_instance_method trait_nuevo, nombre_metodo

    Trait.define (trait_nuevo){ instance_method((nombre_metodo.to_s+'_'+trait_viejo1.to_s).to_sym, &codigo_trait_viejo1)}
    Trait.define (trait_nuevo){ instance_method((nombre_metodo.to_s+'_'+trait_viejo2.to_s).to_sym, &Trait.trait_list_instance[trait_viejo2][nombre_metodo])}

    Trait.define (trait_nuevo){ instance_method(nombre_metodo) do
      self.send (nombre_metodo.to_s+'_'+trait_viejo2.to_s).to_sym;
      self.send (nombre_metodo.to_s+'_'+trait_viejo1.to_s).to_sym;
    end
    }
  end

end


class EstrategiaLLamarATodosYaplicarFuncion
  attr_accessor :funcion

  def initialize(funcion_booleana)
    self.funcion =funcion_booleana
  end

  def resolver_conflictos(trait_nuevo, trait_viejo1, trait_viejo2, nombre_metodo, &codigo_trait_viejo1)
    funcion_a_evaluar = self.funcion

    Trait.remove_instance_method trait_nuevo, nombre_metodo

    Trait.define (trait_nuevo){ instance_method((nombre_metodo.to_s+'_'+trait_viejo1.to_s).to_sym, &codigo_trait_viejo1)}
    Trait.define (trait_nuevo){ instance_method((nombre_metodo.to_s+'_'+trait_viejo2.to_s).to_sym, &Trait.trait_list_instance[trait_viejo2][nombre_metodo])}

    Trait.define (trait_nuevo){ instance_method(nombre_metodo) do
      res1 = self.send (nombre_metodo.to_s+'_'+trait_viejo2.to_s).to_sym;
      if(funcion_a_evaluar.call(res1))
         return res1
      end
      res2 = self.send (nombre_metodo.to_s+'_'+trait_viejo1.to_s).to_sym;
      if(funcion_a_evaluar.call(res2))
        return res2
      end
    end
    }
  end

end


class EstrategiaLLamarATodosFoldeando

  def resolver_conflictos(trait_nuevo, trait_viejo1, trait_viejo2, nombre_metodo, &codigo_trait_viejo1)
    Trait.remove_instance_method trait_nuevo, nombre_metodo

    nombre_metodo_trait_viejo1 = (nombre_metodo.to_s+'_'+trait_viejo1.to_s).to_sym
    nombre_metodo_trait_viejo2 = (nombre_metodo.to_s+'_'+trait_viejo2.to_s).to_sym
    Trait.define (trait_nuevo){ instance_method(nombre_metodo_trait_viejo1, &codigo_trait_viejo1)}
    Trait.define (trait_nuevo){ instance_method(nombre_metodo_trait_viejo2, &Trait.trait_list_instance[trait_viejo2][nombre_metodo])}

    Trait.define (trait_nuevo){ instance_method(nombre_metodo) { |parametro_inicial|
      resultado = self.send nombre_metodo_trait_viejo1, parametro_inicial
      self.send nombre_metodo_trait_viejo2, resultado
      }
    }
  end

end