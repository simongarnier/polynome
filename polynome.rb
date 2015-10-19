require 'pruby'

#
# Classe definissant des polynomes a coefficients entiers.
#
# Plusieurs modes de multiplications sont disponibles: un mode
# sequentiel et diverses modes paralleles.
#
# @note Concernant la mise en oeuvre interne: Un polynome tel que
#    4*x^2+2*x+1 est represente par un Array = [1, 2, 4].  De plus,
#    une representation canonique est utilisee, i.e., une
#    representation unique pour n'importe quel polynome.  Ceci
#    necessite que les 0 non significatifs ne soient pas conserves.
#    Donc, un polynome dont la representation interne contient un ou
#    des 0 en derniere position est invalide... sauf pour le polynome
#    constant 0.
#
class Polynome

  # Pour activer la trace de debogage, on met '#' devant '&&'.
  DEBUG = true && false

  #
  # Les differents modes d'execution, sequentiel ou paralleles.
  #
  MODES = [ :sequentiel, :parallele, :parallele_forkjoin ]

  #
  # Les differentes approches de repartition pour une execution
  # parallele.
  #
  REPARTITIONS = [ :statique, :dynamique ]

  class << self
    #
    # Mode de d'execution a utiliser lors d'un appel a une operation
    # possiblement parallele.
    #
    # Valeur par defaut = :sequentiel, donc la variante sequentielle.
    #
    # @return [nil,Symbol]
    #
    attr_reader :mode

    def mode=( le_mode )
      DBC.check_value le_mode, MODES + [nil], "*** Mode invalide = #{le_mode}"

      @mode = le_mode
    end

    #
    # Approche de repartition des elements entre les threads lors
    # d'une operation parallele.
    #
    # Valeur par defaut = nil.
    #
    # @return [nil, Symbol]
    #
    attr_reader :repartition

    def repartition=( la_repartition )
      DBC.check_value la_repartition, REPARTITIONS + [nil], "*** Repartition invalide = #{repartition}"

      @repartition = la_repartition
    end

    #
    # Nombre de threads a utiliser lors d'une operation parallele.
    #
    # Valeur par defaut = nil
    #
    # @return [nil, Fixnum]
    #
    attr_reader :nb_threads

    def nb_threads=( nbt )
      if nbt
        DBC.check_type nbt, Fixnum, "*** Nb. threads invalide = #{nbt}"
        DBC.require nbt > 0, "*** Nb. threads invalide = #{nbt}"
      end

      @nb_threads = nbt
    end


    #
    # Taille des blocs a utiliser pour une version parallele avec une
    # repartition statique cyclique ou avec une repartition dynamique.
    #
    # Valeur par defaut = nil
    #
    # @return [nil, Fixnum]
    #
    attr_reader :taille_bloc

    def taille_bloc=( tb )
      if tb
        DBC.check_type tb, Fixnum, "*** Taille bloc invalide = #{tb}"
        DBC.require tb > 0, "*** Taille bloc invalide = #{tb}"
      end

      @taille_bloc = tb
    end
  end

  Polynome.mode = :sequentiel
  Polynome.repartition = nil
  Polynome.nb_threads = nil
  Polynome.taille_bloc = nil

  #
  # Creation d'un polynome.
  #
  # @param coeffs [Array<Fixnum>] La liste des coefficients
  # @require Il doit y avoir au moins un coefficient
  # @ensure Les zeros non significatifs du tableau de coefficients sont ignores:
  #    self.canonique?
  # @note La seule exception pour un 0 en dernier coefficient est l'entier 0.
  # @note La seule facon d'obtenir un polynome non-canonique devrait
  #    etre en allant bidouiller dans ses coefficients, qui sont et doivent
  #    rester prives!
  #
  def initialize( *coeffs )
    DBC.require coeffs.size >= 1, "*** Il doit y avoir au moins un coefficient"

    coeffs.pop while coeffs.size > 1 && coeffs.last == 0
    @coeffs = *coeffs
  end

  #
  # Taille du polynome.
  #
  # @return [Fixnum] Le nombre de coefficients (significatifs) du polynome
  #
  def taille
    @coeffs.size
  end

  #
  # Retourne le k-ieme coefficient du polynome.
  #
  # @param k [Fixnum] l'index du coefficient requis
  # @require 0 <= k < taille
  # @return [Fixnum] Le k-ieme coefficient
  #
  def []( k )
    DBC.require 0 <= k && k < taille, "*** k = #{k} vs. taille = #{taille}"

    @coeffs[k]
  end

  #
  # Le polynome est-il egal a 0?
  #
  # @return [Bool]
  #
  def zero?
    taille == 1 && self[0] == 0
  end

  #
  # Le polynome est-il represente de facon canonique, i.e., sans 0 non
  # significatifs?
  #
  # @return [Bool]
  #
  def canonique?
    zero? || self[self.taille-1] != 0
  end

  #
  # Chaine representant le polynome.
  #
  # @return [String]
  #
  def to_s
    return "0" if zero?

    coeffs = []
    (taille-1).step(0, -1) do |k|
      next if self[k] == 0       # On saute les 0
      coeffs << "#{self[k]}"
      coeffs.last << "*x" if k >= 1
      coeffs.last << "^#{k}" if k > 1
    end
    coeffs.join("+")
  end


  #
  # Comparaison d'egalite entre deux polynomes.
  #
  # @param autre [Polynome] L'autre polynome a comparer
  # @require tant self que autre sont representes de facon canonique, i.e.,
  #     sans 0 non significatifs
  # @return [Bool] true ssi self et autre ont exactement les memes
  #     coefficients significatifs
  #
  def ==( autre )
    DBC.require self.canonique? && autre.canonique?, "*** Erreur: arguments non canoniques"
    return false if autre.taille != self.taille
    @coeffs.each_with_index do |coeff, i|
      return false if coeff != autre[i]
    end
    return true
  end

  #
  # Somme de deux polynomes.
  #
  # @param autre [Polynome] L'autre polynome a additionner
  # @return [Polynome] la somme de self et autre
  #
  def +( autre )
    DBC.require self.canonique? && autre.canonique?, "*** Erreur: arguments non canoniques"
    a = []
    [self.taille - 1, autre.taille - 1].max.downto(0) do |index|
      a.unshift((index < self.taille ? self[index] : 0) + (index < autre.taille ? autre[index] : 0))
    end
    return Polynome.new(*a)
  end

  #
  # Valeur d'un polynome en un point.
  #
  # @param x [Fixnum] Point pour lequel le polynome doit etre evalue
  # @return [Fixnum] Valeur du polynome au point x
  #
  def valeur( x )
    def valeur_(x, i = 0, j= @coeffs.count-1, seuil = 0)
      return @coeffs[i] * x ** i if i == j
      return @coeffs[i] * x ** i + @coeffs[j] * x ** j if (j - i).abs == 1

      if !Polynome.taille_bloc.nil? && seuil > Polynome.taille_bloc then
        return @coeffs[i..j].map do |index|
          @coeffs[index] * x ** index
        end.reduce(:+)
      end

      f = PRuby.future { valeur_(x, i, (j+i)/2, seuil + 1) }
      valeur_(x, (j+i)/2+1, j, seuil + 1 ) + f.value
    end
    valeur_(x)
  end

  #
  # Produit de deux polynomes.
  #
  # @param autre [Polynome] L'autre polynome a multiplier
  # @return [Polynome] le produit de self et autre
  # @note Cette methode utilise methode_a_appeler, qui est
  #    essentiellement un 'dispatcher': voir plus bas.
  #
  def *( autre )
    self.send methode_a_appeler, autre
  end

  #
  # Methode qui analyse les parametres de configuration et qui
  # determine quelle methode de multiplication doit effectivement etre
  # utilisee.
  #
  # @return [Symbol] Nom de la methode a appeler
  #
  def methode_a_appeler
    mode = Polynome.mode || :sequentiel

    return :fois_seq if mode == :sequentiel

    Polynome.nb_threads ||= PRuby.nb_threads

    case Polynome.mode
    when :parallele
      if Polynome.repartition.nil? || Polynome.repartition == :statique
        :fois_par_statique
      else
        if Polynome.taille_bloc
          :fois_par_dynamique
        else
          fail "*** Combinaison invalide: #{Polynome.parametres}"
        end
      end
    when :parallele_forkjoin
      if Polynome.repartition == :statique
        Polynome.taille_bloc.nil? ? :fois_forkjoin_bloc : :fois_forkjoin_cyclique
      else
        fail "*** Combinaison invalide: #{Polynome.parametres}"
      end
    end
  end


  private

  def split_range(r)
    rs = r.first + r.last
    [(r.first..rs/2), (rs/2+1..r.last)]
  end

  #
  # Chaine representant l'etat exact des parametres d'execution. Utile
  # pour le debogage.
  #
  def self.parametres
    "[ #{Polynome.mode.inspect}, " <<
      "#{Polynome.repartition.inspect}, " <<
      "taille_bloc = #{Polynome.taille_bloc.inspect}, " <<
      "nb_threads = #{Polynome.nb_threads.inspect} ]"
  end


  #############################################################
  # Les differentes versions de la multiplication, appelees par le
  # 'dispatcher', i.e., la methode '*'.
  #############################################################

  def fois_seq_naif( autre )
    (puts "fois_seq( #{autre} )"; puts Polynome.parametres) if DEBUG
    offset = 0
    a = (autre.taille-1).downto(0).map do |index|
      ret = @coeffs.map do |coeff|
        coeff * autre[index]
      end + offset.times.map{ 0 }
      offset += 1
      ret.reverse
    end
    Polynome.new(*a.last.zip(*a[0...a.size-1]).map{|a| a.compact.reduce(:+)}.reverse.flatten)
  end

  def fois_seq(autre)
    (puts "fois_seq( #{autre} )"; puts Polynome.parametres) if DEBUG
    degree_max = autre.taille-1 + taille-1
    produit = (0...autre.taille).to_a.product((0...taille).to_a)
    coeffs = (0..degree_max).map do |degree|
      produit.select{|a, c| a+c == degree}.reduce(0) do |memo, (a_idx, c_idx)|
        memo += autre[a_idx] * self[c_idx]
      end
    end
    Polynome.new(*coeffs)
  end

   def fois_forkjoin_bloc(autre)
    (puts "fois_forkjoin_bloc( #{autre} )"; puts Polynome.parametres) if DEBUG
    degree_max = autre.taille-1 + taille-1
    produit = (0...autre.taille).to_a.product((0...taille).to_a)
    slicer = degree_max / Polynome.nb_threads
    slicer = 0 ? 1 : slicer
    groups = (0..degree_max).to_a.each_slice(slicer).to_a

    coeffs = Array.new(degree_max)

    work = lambda do |k|
      groups[k].each do |degree|
        coeffs[degree] = produit.select { |a, c| a+c == degree }.reduce(0) do |memo, (a_idx, c_idx)|
          memo + autre[a_idx] * self[c_idx]
        end
      end
    end

    PRuby.pcall 0...groups.size, work

    Polynome.new(*coeffs)
  end

  def fois_forkjoin_cyclique( autre )
    (puts "fois_forkjoin_cyclique( #{autre} )"; puts Polynome.parametres) if DEBUG
    degree_max = autre.taille-1 + taille-1
    produit = (0...autre.taille).to_a.product((0...taille).to_a)
    tasks = TaskBag.new(Polynome.nb_threads)

    (0..degree_max).to_a.each_slice(Polynome.taille_bloc).each { |g| tasks.put g }

    coeffs = Array.new(degree_max)

    work = lambda do |k|
      while group = tasks.get
        group.each do |degree|
          coeffs[degree] = produit.select { |a, c| a+c == degree }.reduce(0) do |memo, (a_idx, c_idx)|
            memo + autre[a_idx] * self[c_idx]
          end
        end
      end
    end

    PRuby.pcall 0...Polynome.nb_threads, work

    Polynome.new(*coeffs)
  end

  # Solution statique non fork-join.
  def fois_par_statique( autre )
    (puts "fois_par_statique( #{autre} )"; puts Polynome.parametres) if DEBUG
    degree_max = autre.taille-1 + taille-1
    produit = (0...autre.taille).to_a.product((0...taille).to_a)
    mode = if Polynome.taille_bloc then
      {static: Polynome.taille_bloc}
    else
      {static: true}
    end
    coeffs = (0..degree_max).pmap(mode) do |degree|
      produit.select{|a, c| a+c == degree}.reduce(0) do |memo, (a_idx, c_idx)|
        memo += autre[a_idx] * self[c_idx]
      end
    end
    Polynome.new(*coeffs)
  end

  # Solution dynamique.
  def fois_par_dynamique( autre )
    (puts "fois_par_dynamique( #{autre} )"; puts Polynome.parametres) if DEBUG
    mode = if Polynome.taille_bloc then
      {dynamic: Polynome.taille_bloc}
    else
      {dynamic: true}
    end
    degree_max = autre.taille-1 + taille-1
    produit = (0...autre.taille).to_a.product((0...taille).to_a)
    coeffs = produit.pmap(mode) do |(a_idx, c_idx)|
      [a_idx + c_idx, autre[a_idx] * self[c_idx]]
    end.inject((degree_max + 1).times.map{0}) do |memo, (degree, coeff)|
      memo[degree] += coeff
      memo
    end
    Polynome.new(*coeffs)
  end

end
