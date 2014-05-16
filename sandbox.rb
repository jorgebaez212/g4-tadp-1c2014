require 'rspec'
require_relative './TFramework/ObjectSetUp.rb'
require_relative './TFramework/SymbolSetUp.rb'

describe 'Test crea metodos' do
  before :all do

    Trait.define(:T) {
      c_meth(:printHi) {puts 'Hola, mi nombre de metodo de clase es printHi'}
      i_meth(:printHi2) {puts 'Hola, mi nombre de metodo de instancia es printHi2'}
      i_meth(:uno) {1}
      i_meth(:dos) {2}
    }


    Trait.define(:T2) do
      c_meth(:printHi3) {puts 'Hola, mi nombre de metodo de clase es printHi3'}
      i_meth(:printHi4) {puts 'Hola, mi nombre de metodo de instancia es printHi4'}
      i_meth(:dos) {2}
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
      c_meth(:print_A) {puts 'Hola, mi nombre de metodo de clase es printHi1'}
      i_meth(:print_B) {puts 'Hola, mi nombre de metodo de instancia es printHi2'}
      c_meth(:print_C) {puts 'Hola, mi nombre de metodo de clase es printHi3'}
      i_meth(:print_D) {puts 'Hola, mi nombre de metodo de instancia es printHi4'}
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

    Trait.trait_list_instance.each{|key,value| puts 'Trait: '+key.to_s; value.each{|key,value| puts key.to_s}}

  end

  it 'usa dos traits que tienen un metedo repetido y tira excepcion' do
    class Conflicto
      uses :T+:T2
    end

    c = Conflicto.new

    c.should respond_to?(:uno) == true
    c.should_not respond_to?(:dos) == true
    c.uno.should == 1
    expect {
      c.dos
    }.to raise_error NoMethodError

  end
end