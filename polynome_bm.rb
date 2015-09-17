#
# Programme pour mesurer les performances des diverses versions de la
# multiplication parallele.
#
# Les parametres sont specifies par l'intermediaire de variables
# d'environnement, et sont evidemment optionnels:
#
# - TAILLE [Fixnum] Taille des polynomes
# - NB_THREADS [Fixnum [,Fixnum]*] Nombres de threads a utiliser
# - VERSIONS [version [,version]*] Versions a executer
#

require 'benchmark'
require_relative 'polynome'
require_relative 'configurer_multiplications'

#
# Pour verifier les resultats produits par chaque version parallele:
# on verifie alors que le resultat est le meme que la version
# sequentielle.
#
AVEC_VERIFICATION = true # && false


###############################################################
# Taille des polynomes a generer.
###############################################################
TAILLE_DEFAUT = 1024

TAILLE = ENV['TAILLE'] ? ENV['TAILLE'].to_i : TAILLE_DEFAUT


###############################################################
# Nombres de threads a comparer.
###############################################################
NB_THREADS_DEFAUT = [2, 4, 8, 16, 32, 64, 128]

if nb_threads = ENV['NB_THREADS']
  NB_THREADS = nb_threads.split(',').map(&:to_i)
else
  NB_THREADS = NB_THREADS_DEFAUT
end


###############################################################
# Versions a 'benchmarker'.
###############################################################
VERSIONS_DEFAUT = [
                   "P:S::",
                   "P:S:1:",
                   "P:S:5:",
                   "P:D:1:",
                   "P:D:5:",
                   "PFJ:S::",
                   "PFJ:S:1:",
                   "PFJ:S:5:",
                  ]

if versions = ENV['VERSIONS']
  VERSIONS = versions.split(',')
else
  VERSIONS = VERSIONS_DEFAUT
end


###############################################################
# Nombre de fois ou on repete l'execution.
###############################################################
NB_FOIS_DEFAUT = 3

NB_FOIS = ENV['NB_FOIS'] ? ENV['NB_FOIS'].to_i : NB_FOIS_DEFAUT

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
# Calcul et ecriture du temps et de l'acceleration.
###############################################################
def ecrire_acc( taille, nbt, produit, temps, temps_seq )
  acc = temps_seq / temps
  puts "[#{'%d' % taille}] (#{'%3d' % nbt}) #{'%-10s' % produit}: #{'%8.3f' % temps}\t#{'%5.1f' % acc}"
end


###############################################################
# Les benchmarks.
###############################################################

NB_THREADS.each do |nb_threads|
  p1 = Polynome.new( *1..TAILLE )
  p2 = Polynome.new( *1..TAILLE )

  # On mesure le temps de la version sequentielle, pour calculer
  # l'acceleration.
  Polynome.mode = :sequentiel
  p_ok = nil
  temps_seq = temps_moyen(NB_FOIS) { p_ok = p1 * p2 }
  ecrire_acc TAILLE, nb_threads, 'S:::', temps_seq, temps_seq

  # On mesure le temps des diverses versions paralleles.
  VERSIONS.each do |methode|
    configurer_version( methode )
    PRuby.nb_threads = nb_threads
    p = nil
    temps_par = temps_moyen(NB_FOIS) { p = p1 * p2 }
    DBC.require p == p_ok if AVEC_VERIFICATION
    ecrire_acc TAILLE, nb_threads, methode, temps_par, temps_seq
  end
  puts
end
