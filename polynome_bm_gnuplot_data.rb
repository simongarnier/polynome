require 'benchmark'
require_relative 'polynome'
require_relative 'configurer_multiplications'

#
# Programme pour mesurer les performances des diverses versions du
# produit de polynomes
#
# Les parametres sont specifies par l'intermediaire de variables
# d'environnement, et sont evidemment optionnels:
#
# - METHODES [methode [,methode]*] Methodes a executer
# - TAILLE [Fixnum] Taille du tableau a generer et traiter
#

###############################################################
# Taille des polynomes a generer.
###############################################################
TAILLE_DEFAUT = 1024

TAILLE = ENV['TAILLE'] ? ENV['TAILLE'].to_i : TAILLE_DEFAUT

###############################################################
# Nombre de fois ou on repete l'execution.
###############################################################
NB_FOIS_DEFAUT = 20 # Pour plus d'uniformite de moyenne

NB_FOIS = ENV['NB_FOIS'] ? ENV['NB_FOIS'].to_i : NB_FOIS_DEFAUT


###############################################################
# Pour verifier les resultats produits par la version parallele: si
# true, on verifie que le resultat est le meme que pour la methode
# sequentielle.
###############################################################
AVEC_VERIFICATION = true # && false


###############################################################
# Methodes *paralleles* a 'benchmarker'.  La version sequentielle est
# toujours executee avant les versions paralleles et son temps imprime
# au debut de chaque ligne, pour permettre les mesures ulterieures
# d'acceleration.
###############################################################
METHODES_DEFAUT = [
                   "P:S::",
                   "P:S:1:",
                   "P:S:20:",
                   "P:D:1:",
                   "P:D:20:",
                   "PFJ:S::",
                   "PFJ:S:1:",
                   "PFJ:S:20:",
                  ]

if methodes = ENV['METHODES']
  METHODES = methodes.split(',')
else
  METHODES = METHODES_DEFAUT
end


###############################################################
# Execution repetitive pour calcul de temps moyen.
###############################################################

def temps_moyen( nb_fois, &block )
  return 0.0 if nb_fois == 0

  tot = 0
  nb_fois.times do
    tot += (Benchmark.measure &block).real
  end

  tot / nb_fois
end

###############################################################
# Les benchmarks.
###############################################################

# On genere les deux polynomes.
p1 = Polynome.new( *1..TAILLE )
p2 = Polynome.new( *1..TAILLE )

# On imprime l'information sur la taille du probleme.
puts "# TAILLE = #{TAILLE}"

# On imprime les en-tetes de colonnes.
largeur = METHODES.map(&:size).max + 2
print "# nb.th."
["seq", *METHODES].each do |x|
  print x.rjust(largeur)
end
puts

# On mesure et on imprime le temps des diverses versions.
[1, 2, 4, 8, 16, 32, 64, 128, 256].each do |nb_threads|
  PRuby.nb_threads = nb_threads

  print "%8d" % nb_threads

  # On execute la version sequentielle.
  Polynome.mode = :sequentiel
  p_ok = nil
  temps_seq = temps_moyen(NB_FOIS) { p_ok = p1 * p2 }
  print "%#{largeur}.3f" % temps_seq

  # On execute les versions paralleles.
  METHODES.each do |methode|
    ENV['METHODE'] = methode

    configurer_version( methode )

    p = nil
    temps_par = temps_moyen(NB_FOIS) { p = p1 * p2 }
    print "%#{largeur}.3f" % temps_par

    DBC.require p == p_ok if AVEC_VERIFICATION
  end
  puts
end
