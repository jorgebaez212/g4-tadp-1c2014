require 'rspec'
require_relative './TFramework/ObjectSetUp.rb'
require_relative './TFramework/SymbolSetUp.rb'

describe 'Test crea metodos' do
  before :all do
    Trait.define :T,
                 c_meth(:printHi) {puts 'Hola, mi nombre de metodo de clase es printHi'},
                 i_meth(:printHi2) {puts 'Hola, mi nombre de metodo de instancia es printHi2'}

    Trait.define :T2,
                 c_meth(:printHi3) {puts 'Hola, mi nombre de metodo de clase es printHi3'},
                 i_meth(:printHi4) {puts 'Hola, mi nombre de metodo de instancia es printHi4'}
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

    (Trait.trait_list_instance.has_key? :T_T2).should == true
#   Trait.trait_list_instance.each{|key,value| puts 'Trait: '+key.to_s; value.each{|key,value| puts key.to_s}}
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
end