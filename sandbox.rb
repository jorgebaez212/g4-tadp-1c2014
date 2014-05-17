require 'rspec'
require_relative './TFramework/ObjectSetUp.rb'
require_relative './TFramework/SymbolSetUp.rb'

describe 'Test crea metodos' do
  before :all do

    Trait.define(:T) {
      class_method(:printHi) {puts 'Hola, mi nombre de metodo de clase es printHi'}
      instance_method(:printHi2) {puts 'Hola, mi nombre de metodo de instancia es printHi2'}
    }


    Trait.define(:T2) do
      class_method(:printHi3) {puts 'Hola, mi nombre de metodo de clase es printHi3'}
      instance_method(:printHi4) {puts 'Hola, mi nombre de metodo de instancia es printHi4'}
    end

    Trait.define(:T3) {
      instance_method(:metodoNoRepetido) {'Soy un metodo sin repetir'}
      instance_method(:metodoRepetido) {'Soy el metodo repetido en T'}
    }


    Trait.define(:T4) do
      instance_method(:metodoRepetido) {'Soy el metodo repetido en T2'}
    end

    Trait.define(:TraitConflictivo) do
      instance_method(:metodoConflictivo) {'Soy un metodo conflictivo de trait'}
    end

    Trait.define(:T5) do
      instance_method(:un_metodo) {5}
      instance_method(:metodo_repetido_numero) {5}
    end

    Trait.define(:T6) do
      instance_method(:un_metodo) {6}
      instance_method(:metodo_repetido_numero) {6}
    end

    Trait.define(:T7) do
      instance_method(:metodo_repetido_numero) {-7}
    end

    Trait.define(:T8) do
      instance_method(:metodo_repetido_numero) {8}
    end

  end

  it 'agrega metodo simple' do
    class Prueba
      uses :T+:T2
    end

    p = Prueba.new

    Prueba.should respond_to(:printHi)
    Prueba.should_not respond_to(:printHi2)
    p.should respond_to(:printHi2)
    p.should_not respond_to(:printHi)

    #(Trait.trait_list_instance.has_key? :T_T2).should == true
  end

  it 'agrega metodo y luego cambia a alias' do
    class Prueba2
      uses :T << (:printHi2 < :printHi100)
    end

    p = Prueba2.new

    p.should respond_to(:printHi100)
    p.should_not respond_to(:printHi2)

    (Trait.trait_list_instance.has_key? :T_i_printHi100).should == true
  end

  it 'usa un trait sacandole algunos metodos' do

    Trait.define(:T) {
      class_method(:print_A) {puts 'Hola, mi nombre de metodo de clase es printHi1'}
      instance_method(:print_B) {puts 'Hola, mi nombre de metodo de instancia es printHi2'}
      class_method(:print_C) {puts 'Hola, mi nombre de metodo de clase es printHi3'}
      instance_method(:print_D) {puts 'Hola, mi nombre de metodo de instancia es printHi4'}
    }

    class PruebaResta
      uses :T - [:print_B ,:print_C] +:T2
    end

    PruebaResta.should respond_to(:print_A)
    PruebaResta.should_not respond_to(:print_B)
    PruebaResta.should_not respond_to(:print_C)
    PruebaResta.should_not respond_to(:print_D)
    PruebaResta.should respond_to(:printHi3)
    PruebaResta.should_not respond_to(:printHi4)

    p = PruebaResta.new
    p.should_not respond_to(:print_A)
    p.should_not respond_to(:print_B)
    p.should_not respond_to(:print_C)
    p.should respond_to(:print_D)
    p.should_not respond_to(:printHi3)
    p.should respond_to(:printHi4)

    #Trait.trait_list_instance.each{|key,value| puts 'Trait: '+key.to_s; value.each{|key,value| puts key.to_s}}

  end

  it 'usa dos traits que tienen un metedo repetido y tira excepcion' do
    class Conflicto
      uses :T3+:T4
    end

    c = Conflicto.new

    c.should respond_to(:metodoNoRepetido)
    c.should respond_to(:metodoRepetido)
    expect{c.metodoRepetido}.to raise_error ConflicException
  end

  it 'usa trait que ya tiene un metodo existente en instancia de clase y se queda con el metodo de clase' do
   class Conflicto2
      uses :TraitConflictivo
      def metodoConflictivo
        'Soy un metodo conflictivo de instancia'
      end
   end

   c = Conflicto2.new

   c.should respond_to(:metodoConflictivo)

   c.metodoConflictivo.should eq 'Soy un metodo conflictivo de instancia'
  end

  it 'usa trait que tienen un metodo con mismo nombre y al ejecutarlo en la clase ejecuta los del trait' do
    class Conflicto3
      strategy EstrategiaLLamarATodos.new # 1: ejecuto todos los metodos repetidos en orden
      uses :T5 + :T6
    end

    c = Conflicto3.new

    c.should respond_to(:un_metodo_T5)
    c.should respond_to(:un_metodo_T6)
    c.should respond_to(:un_metodo)
    c.un_metodo.should == 6
  end

  it 'usa trait que tienen un metodo con mismo nombre y al ejecutarlo en la clase ejecuta los del trait' do
    class Conflicto4
      strategy EstrategiaLLamarATodos.new # 1: ejecuto todos los metodos repetidos en orden
      uses :T6 + :T5
    end

    c = Conflicto4.new

    c.should respond_to(:un_metodo_T5)
    c.should respond_to(:un_metodo_T6)
    c.should respond_to(:un_metodo)
    c.un_metodo.should == 5
  end

  it 'usa trait que tienen un metodo con mismo nombre y al ejecutarlo en la clase ejecuta los del trait' do
    class Conflicto5
      strategy EstrategiaLLamarATodosYaplicarFuncion.new(Proc.new {|numero| numero>0})  # 1: ejecuto todos los metodos repetidos en orden
      uses :T7 + :T8 + :T5 + :T6
    end

    c = Conflicto5.new

    c.should respond_to(:metodo_repetido_numero)
    c.metodo_repetido_numero.should == 8
  end
end















