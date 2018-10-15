require_relative 'hex_mini_test'
require_relative '../../src/externals'

class TestBase < HexMiniTest

  def port(kata_id, avatar_name)
    porter.port(kata_id, avatar_name)
  end

  # - - - - - - - - - - - - - - - - -

  def externals
    @externals ||= Externals.new
  end

  private

  def saver
    externals.saver
  end

  def storer
    externals.storer
  end

end