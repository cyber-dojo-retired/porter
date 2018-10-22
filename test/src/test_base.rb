require_relative 'hex_mini_test'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def port(kata_id)
    porter.port(kata_id)
  end

  # - - - - - - - - - - - - - - - - -

  def externals
    @externals ||= Externals.new
  end

  private

  def porter
    externals.porter
  end

  def saver
    externals.saver
  end

  def storer
    externals.storer
  end

end