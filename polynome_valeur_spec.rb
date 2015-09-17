require_relative 'spec_helper'
require_relative 'polynome'

describe Polynome do
  describe "#valeur" do
    it "retourne le coefficient 0 pour x = 0" do
      p = Polynome.new( 10, 30, 0, 40 )
      p.valeur(0).must_equal 10
    end

    it "retourne la somme des coefficients pour x = 1" do
      coeffs = [ 10, 30, 0, 40 ]
      p = Polynome.new *coeffs
      p.valeur(1).must_equal coeffs.reduce(&:+)
    end

    it "retourne la somme des coefficients pour x = 1 et un grand nombre de coefficients" do
      coeffs = [*0..200]
      p = Polynome.new *coeffs
      p.valeur(1).must_equal coeffs.reduce(&:+)
    end

    it "retourne la representation decimale pour x = 10 et des coefficients 0 a 9" do
      coeffs = [ 1, 3, 0, 4, 8, 7, 9, 9, 9, 6, 8, 8 ]
      p = Polynome.new *coeffs
      p.valeur(10).must_equal 886999784031
    end

    it "retourne la representation decimale pour x = 10 et des coefficients 0 a 9, avec taille_bloc = nil" do
      coeffs = [ 1, 3, 0, 4, 8, 7, 9, 9, 9, 6, 8, 8 ]
      p = Polynome.new *coeffs

      Polynome.taille_bloc = nil
      p.valeur(10).must_equal 886999784031
    end


    it "retourne la representation decimale pour x = 10 et des coefficients 0 a 9, avec taille_bloc > 1" do
      coeffs = [ 1, 3, 0, 4, 8, 7, 9, 9, 9, 6, 8, 8 ]
      p = Polynome.new *coeffs

      Polynome.taille_bloc = 5
      p.valeur(10).must_equal 886999784031
    end

  end
end
