require_relative 'polynome'

######################################################################
# Configuration des tests pour les diverses sortes de multiplication.
######################################################################


#
# Par defaut, on teste plusieurs variantes de multiplication... a
# moins que la variable d'environnement VERSIONS ne specifie une ou
# plusieurs versions specifiques. Ceci se fait alors avec un appel a
# rake tels que les suivants:
#
# $ export VERSIONS=PFJ:S:3:5
# $ rake
# $ export VERSIONS=S:::,PFJ:S:3:5,P:D:2:
# $ rake
#
# Un tel appel specifie alors la configuration suivante pour la
# multiplication:
#   - Parallelisme fork-join
#   - Repartition statique entre les threads
#   - Taille des taches = 3
#   - Nombre de threads = 5
#
#
# Contraintes:
#
# - Les trois separateurs ':' doivent necessairement etre presents.
#
# - Le nombre de threads peut toujours etre omis, auquel cas on
#   utilise PRuby.nb_threads
#
# - La taille des taches peut etre omise, sauf dans le cas dynamique.
#   Lorsqu'omis dans le cas statique, ceci implique une repartition
#   par bloc d'elements adjacents.
#

$multiplications_a_tester = [
                             "S:::",
                             "P:S::",
                             "P:S:1:",
                             "P:S:3:",
                             "P:D:1:",
                             "P:D:3:",
                             "PFJ:S::",
                             "PFJ:S:1:",
                             "PFJ:S:3:",
                            ]


if versions = ENV['VERSIONS']
  $multiplications_a_tester = versions.split(',')
end

#
# Pour configurer les parametres de la classe Polynome, notamment a
# partir des valeurs de la variable VERSIONS qui peut avoir ete
# specifiee.
#
# @param version [String] La chaine fournie specifiant les parametres de la version a tester
#
def configurer_version( version )
  modes = {
    "S" => :sequentiel,
    "P" => :parallele,
    "PFJ" => :parallele_forkjoin,
  }

  repartitions = {
    "S" => :statique,
    "D" => :dynamique,
  }

  version =~ /(\w+)\:(\w*)\:(\d*):(\d*)/
  mode, repartition, taille_bloc, nb_threads = $1, $2, $3, $4

  Polynome.mode = modes[mode] || :sequentiel

  Polynome.repartition = (repartition == '') ? nil : repartitions[repartition]

  Polynome.taille_bloc = (taille_bloc == '') ? nil : taille_bloc.to_i

  Polynome.nb_threads = (nb_threads == '') ? PRuby.nb_threads : nb_threads.to_i
end
