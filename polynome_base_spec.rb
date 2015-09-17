require_relative 'spec_helper'
require_relative 'polynome'

describe Polynome do
  describe "#[]" do
    it "accede aux coefficients d'un simple entier" do
      p = Polynome.new( 10 )
      p[0].must_equal 10
      lambda { p[-1] }.must_raise DBC::Failure
      lambda { p[1] }.must_raise DBC::Failure
    end

    it "accede aux coefficients d'un polynome avec plusieurs elements" do
      p = Polynome.new( 10, 20, 0, 30 )
      p[0].must_equal 10
      p[1].must_equal 20
      p[2].must_equal 0
      p[3].must_equal 30
      lambda { p[4] }.must_raise DBC::Failure
    end
  end

  describe ".new" do
    it "supprime les zeros non significatifs" do
      p = Polynome.new( 10, 0, 30, 0, 0 )
      p[0].must_equal 10
      p[1].must_equal 0
      p[2].must_equal 30
      lambda { p[3] }.must_raise DBC::Failure
    end

    it "supprime les zeros non significatifs sauf si ce doit etre le seul" do
      p = Polynome.new( 0, 0, 0, 0, 0 )
      p[0].must_equal 0
      lambda { p[1] }.must_raise DBC::Failure
    end
  end

  describe "#zero?" do
    it "retourne true pour 0" do
      Polynome.new( 0, 0, 0 ).zero?.must_equal true
    end

    it "retourne false pour un polynome constant" do
      Polynome.new( 2, 0, 0 ).zero?.must_equal false
    end

    it "retourne false pour un polynome complexe" do
      Polynome.new( 2, 0, 2, 3, 0 ).zero?.must_equal false
    end
  end

  describe "#canonique?" do
    it "retourne true pour 0" do
      Polynome.new( 0, 0, 0 ).canonique?.must_equal true
    end

    it "retourne true pour un polynome constant" do
      Polynome.new( 2, 0, 0 ).canonique?.must_equal true
    end

    it "retourne true pour un polynome complexe" do
      Polynome.new( 0, 2, 0, 2, 3, 0, 0, 0 ).canonique?.must_equal true
    end

    it "retourne false pour un polynome avec un 0 en derniere position" do
      # La seule facon pour obtenir un polynome non-canonique devrait
      # etre d'aller bidouiller a l'interieur de son tableau de
      # coefficients!
      p = Polynome.new( 2, 0, 2, 3, 0 )
      p.instance_eval { @coeffs[-1] = 0 }
      p.canonique?.must_equal false
    end
  end

  describe "to_s" do
    it "retourne 0 meme s'il y a plusieurs 0" do
      Polynome.new(0, 0).to_s.must_equal "0"
    end

    it "retourne un simple entier pour un polynome de taille 1" do
      Polynome.new(2).to_s.must_equal "2"
    end

    it "retourne un x sans exposant pour un polynome de taille 2" do
      Polynome.new(1, 2).to_s.must_equal "2*x+1"
    end

    it "retourne les exposants appropries pour un polynome de taille 3" do
      Polynome.new(1, 2, 4).to_s.must_equal "4*x^2+2*x+1"
    end

    it "ignore les 0 au milieu" do
      Polynome.new(1, 0, 4, 0, 5).to_s.must_equal "5*x^4+4*x^2+1"
    end

    it "ignore les 0 au debut, au milieu et a la fin" do
      Polynome.new(0, 0, 4, 0, 5, 0).to_s.must_equal "5*x^4+4*x^2"
    end
  end
end
