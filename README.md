TP Traits - 1C2014 TADP - Grupo 4
============================

Implementación de composición de objetos similar a Traits consu álgebra incluida.

## Definición de Traits

Todo Trait a definir se deberá declarar de la siguiente forma:


	Trait.define(:NombreTrait) {
	
		c_meth(:NombreMetodoDeClase) {puts 'Esto sería parte del bloque de código del método de clase'}
		
		i_meth(:NombreMetodoDeInstancia) {puts 'Esto sería parte del bloque de código del método de instancia'}
		
    	}

## Uso de los Traits

##### Para utilizar los Traits, se deberá utilizar en la declaración de las clases la siguiente sintaxis:

	class Prueba
		uses :Trait_1
	end

##### Si se quieren sumar Traits:

	class Prueba
		uses :Trait_1 + :Trait_2
	end

##### Si se desea no utilizar algunos métodos de un trait:

	class Prueba
		uses (:Trait_1 - [:Metodo_1 ,:Metodo_2]) + :T2
	end

O simplemente:

	class Prueba
		uses :Trait_1 - [:Metodo_1 ,:Metodo_2] + :T2
	end

##### Por default existe una estrategia para resulucion de conflictos que lanza una excepcion al llamar al metodo conflictivo, en caso de quuerer asignar otra usar la siguiente sintaxis:
	
	class Prueba
		strategy EstrategiaLLamarATodos.new 
		uses :T1 + :T2
	end

	class Prueba
		strategy EstrategiaLLamarATodosFoldeando.new 
		uses :T1 + :T2
	end

	class Prueba
		strategy EstrategiaLLamarATodosYaplicarFuncion.new(Proc.new {|numero| numero>0})
		uses :T1 + :T2
	end



