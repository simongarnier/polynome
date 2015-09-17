require_relative 'spec_helper'
require_relative 'polynome'

describe Polynome do
  describe "#==" do
    it "retourne qu'un polynome est egal a lui-meme" do
      p = Polynome.new( 10, 30, 0, 40 )
      (p == p).must_equal true
    end

    it "ignore les zeros non significatifs" do
      p1 = Polynome.new( 10, 30, 0, 40 )
      p2 = Polynome.new( 10, 30, 0, 40, 0, 0, 0 )
      (p1 == p2).must_equal true
    end

    it "retourne false des qu'un coefficient est different" do
      p1 = Polynome.new( 10, 30, 0, 40 )
      p2 = Polynome.new( 10, 0, 0, 40, 0, 0, 0 )
      (p1 == p2).must_equal false
    end

    it "assure que c'est commutatif lorsque false" do
      p1 = Polynome.new( 10, 30, 0, 40 )
      p2 = Polynome.new( 10, 0, 0, 40, 0, 0, 0 )
      (p1 == p2).must_equal (p2 == p1)
    end

  end

  describe "#+" do
    it "retourne la somme de deux polynomes de meme taille" do
      p1 = Polynome.new( 10, 30, 0, 40 )
      p2 = Polynome.new( 10, 30, 0, 40 )
      (p1 + p2).must_equal Polynome.new( 20, 60, 0, 80 )
      (p2 + p1).must_equal Polynome.new( 20, 60, 0, 80 )
    end

    it "retourne la somme de deux polynomes de tailles differentes" do
      p1 = Polynome.new( 10, 30 )
      p2 = Polynome.new( 10, 30, 0, 40, 80 )
      (p1 + p2).must_equal Polynome.new( 20, 60, 0, 40, 80 )
      (p2 + p1).must_equal Polynome.new( 20, 60, 0, 40, 80 )
    end

    it "retourne la somme de deux polynomes avec des zeros non significatifs" do
      p1 = Polynome.new( 10, 30, 0, 40, 0, 0 )
      p2 = Polynome.new( 10, 30, 0, 40, 0, 0, 0 )
      (p1 + p2).must_equal Polynome.new( 20, 60, 0, 80 )
      (p2 + p1).must_equal Polynome.new( 20, 60, 0, 80 )
    end


    it "retourne la bonne somme pour de tres gros polynomes" do
      nb_coeffs = 1024
      coeffs1 = (0...nb_coeffs).map { |k| k+1 }
      coeffs2 = (0...nb_coeffs).map { |k| 2*k }
      coeffs3 =  (0...nb_coeffs).map { |k| 3 * k + 1 }
      p1 = Polynome.new( *coeffs1 )
      p2 = Polynome.new( *coeffs2 )
      p3 = Polynome.new( *coeffs3 )

      (p1 + p2).must_equal p3
      (p2 + p1).must_equal p3
    end
  end

  describe "#* (version sequentielle)" do
    before do
      Polynome.mode = :sequentiel
    end


    it "mulitplie deux petits polynomes de tailles differentes" do
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

  end
end
