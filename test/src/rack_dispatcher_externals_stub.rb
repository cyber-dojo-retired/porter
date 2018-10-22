
class RackDispatcherExternalsStub

  def initialize(stub)
    @stub = stub
  end

  attr_reader :stub

  def porter
    stub
  end

  def image
    stub
  end

end