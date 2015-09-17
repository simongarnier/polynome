gem 'minitest'
require 'minitest/autorun'

##########################################
# Operations pour ignorer certains tests.
##########################################

class Object
  # Pour ignorer temporairement certains tests.

  def _describe( test )
    puts "--- On ignore les tests \"#{test}\" ---"
  end

  def _it( test )
    puts "--- On ignore les tests \"#{test}\" ---"
  end
end
