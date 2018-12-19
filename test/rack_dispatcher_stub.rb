
class RackDispatcherStub

  def sha
    "hello from #{self.class.name}.sha"
  end

  def port_one(_kata_id)
    "hello from #{self.class.name}.port_one"
  end

end
