require_relative 'spec_helper'
require_relative 'polynome'
require_relative 'configurer_multiplications'

#
# Teste les differentes formes de multiplication, avec divers nombres
# de threads.
#
nb_threads = [2, 5]

describe Polynome do
  describe "#*" do
    $multiplications_a_tester.each do |version|
      nb_threads.each do |nb_threads|
        describe "#{version}" do
          before do
            configurer_version( version )
            Polynome.nb_threads = nb_threads
          end

          it "multiplie deux 'gros' polynomes et compare avec sequentiel" do
            n1 = 399
            n2 = 200
            p1 = Polynome.new( *((1..n1).map{ |i| 10 * i + 2 }) )
            p2 = Polynome.new( *((1..n2).map{ |i| 20 * i - 1 }) )
            r_par = p1 * p2

            Polynome.mode = :sequentiel
            r_seq = p1 * p2

            r_par.must_equal r_seq
          end
        end
      end
    end
  end
end
