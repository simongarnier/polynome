###############################################################
# Constante a completer.
###############################################################

### Vous devez completer l'une ou l'autre des constantes.   ###

# Deux etudiants:
# Si vous etes deux etudiants: Indiquer vos codes permanents.
CODES_PERMANENTS='ABCD01020304,GHIJ11121314'


# Un etudiant:
# Si vous etes seul: Supprimer le diese en debut de ligne et 
# indiquer votre code permanent (sans changer le nom de la variable).
#CODES_PERMANENTS='ABCD01020304'

###################################################################

require 'rake/testtask'
require 'rake/clean'

##################################################
# Pour indiquer une ou des versions paralleles
# specifiques a tester.
##################################################
versions = 'PFJ:S::'
versions = nil

##################################################
# Variables de configuration.
##################################################

OPTIONS=''
VERSIONS= versions ? "export VERSIONS='#{versions}';" : ''


##################################################
# La tache par defaut, pour appel simple a "rake".
# Pour changer cette tache par defaut, il suffit
# d'ajouter/retirer le "_" apres ":".
##################################################

task :default => [:seq]
task :_default => [:valeur]
task :_default => [:multiplication_par1]
task :_default => [:multiplication_par2]

task :_default => [:benchmark]


##################################################
# Les differentes taches
##################################################

task :all => [:base, :seq, :valeur, :multiplication_par1, :multiplication_par2]

desc "Tests pour les operations de base deja definies"
task :base do
  sh %{ruby #{OPTIONS} polynome_base_spec.rb}
end

desc "Tests pour les operations sequentielles (==, + et *)"
task :seq do
  sh %{ruby #{OPTIONS} polynome_seq_spec.rb}
end

desc "Tests pour l'evaluation de la valeur d'un polynome"
task :valeur do
  sh %{ruby #{OPTIONS} polynome_valeur_spec.rb}
end

desc "Tests de base pour les multiplications paralleles"
task :multiplication_par1 do
  sh %{#{VERSIONS} ruby #{OPTIONS} polynome_multiplication_par1_spec.rb}
end

task :p1 => [:multiplication_par1]

desc "Autres tests pour les multiplications paralleles, avec nombre de threads variable"
task :multiplication_par2 do
  sh %{#{VERSIONS} ruby #{OPTIONS} polynome_multiplication_par2_spec.rb}
end

task :p2 => [:multiplication_par2]

desc "Benchmarks des differentes versions de multiplication parallele"
task :benchmark do
 sh %{ruby polynome_bm.rb}
end

task :bm => [:benchmark]

desc "Generation de la documentation avec yard, de facon locale"
task :doc do
  sh %{yard --tag ensure:"Ensures" --tag require:"Requires" doc polynome.rb}
end

desc "Remise du travail avec oto"
task :remise do
  pwd = ENV['PWD']
  sh %{ssh oto.labunix.uqam.ca oto rendre_tp tremblay_gu INF5171 #{CODES_PERMANENTS} #{pwd}/polynome.rb}
  sh %{ssh oto.labunix.uqam.ca oto confirmer_remise tremblay_gu INF5171 #{CODES_PERMANENTS}}
end

