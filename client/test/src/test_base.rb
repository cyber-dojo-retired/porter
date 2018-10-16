require_relative 'hex_mini_test'
require_relative '../../src/porter_service'

class TestBase < HexMiniTest

  def porter
    PorterService.new
  end

end
