require_relative 'spec_helper'
require_relative 'polynome'
require_relative 'configurer_multiplications'

describe Polynome do
  describe "#*" do
    $multiplications_a_tester.each do |version|
      describe "#{version}" do
        before do
          configurer_version( version )
        end


        it "multiplie deux petits polynomes de tailles differentes" do
          p1 = Polynome.new( 1, 2 )
          p2 = Polynome.new( 10, 20, 30, 40 )
          r = Polynome.new( 10, 40, 70, 100, 80 )
          (p1 * p2).must_equal r
        end

        it "multiplie deux 'moyens' polynomes" do
          n = 40
          p1 = Polynome.new( *((1..n).map{ 1 }) )
          p2 = Polynome.new( *((1..n).map{ 1 }) )
          moitie = (1..n).map{ |i| i }
          r = Polynome.new( *(moitie + moitie.reverse[1..-1]) )
          (p1 * p2).must_equal r
        end

        it "mulitiplie deux 'moyens' polynomes avec granularite tres fine" do
          n = 40
          Polynome.nb_threads = 2*n-1
          p1 = Polynome.new( *((1..n).map{ 1 }) )
          p2 = Polynome.new( *((1..n).map{ 1 }) )
          moitie = (1..n).map{ |i| i }
          r = Polynome.new( *(moitie + moitie.reverse[1..-1]) )
          (p1 * p2).must_equal r
        end

        it "mulitiplie deux 'moyens' polynomes avec granularite tres fine" do
          n = 40
          Polynome.nb_threads = 2*n-1
          p1 = Polynome.new( *((1..n).map{ 1 }) )
          p2 = Polynome.new( *((1..n).map{ 1 }) )
          moitie = (1..n).map{ |i| i }
          r = Polynome.new( *(moitie + moitie.reverse[1..-1]) )
          (p1 * p2).must_equal r
        end

        it "mulitiplie deux 'moyens' polynomes avec granularite tres fine et taille_bloc explicite a 1" do
          n = 40
          Polynome.nb_threads = 2*n-1
          Polynome.taille_bloc = 1
          p1 = Polynome.new( *((1..n).map{ 1 }) )
          p2 = Polynome.new( *((1..n).map{ 1 }) )
          moitie = (1..n).map{ |i| i }
          r = Polynome.new( *(moitie + moitie.reverse[1..-1]) )
          (p1 * p2).must_equal r
        end


      end
    end
  end
end
