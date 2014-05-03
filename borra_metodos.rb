require 'rspec'

class BorradorDeMetodos
  def borra_metodo a_method, a_class
    a_class.send :remove_method, a_method
  end
end

class Numero
  def dame_el_uno
    1
  end
end

class NumeroPar < Numero
  def dame_el_dos
    2
  end
end


describe 'Test que borra metodos' do

  it 'primero_entiende_todo_y_despues_ya_no' do
    a_number = NumeroPar.new
    a_number.dame_el_uno.should == 1
    a_number.dame_el_dos.should == 2

    a = BorradorDeMetodos.new
    a.borra_metodo(:dame_el_dos, a_number.class)

    expect {
      a_number.dame_el_dos
    }.to raise_error NoMethodError
  end
end









