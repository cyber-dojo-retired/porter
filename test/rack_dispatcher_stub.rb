
class RackDispatcherStub

  def ready
    "hello from #{self.class.name}.ready"
  end

  def sha
    "hello from #{self.class.name}.sha"
  end

  def port(_kata_id)
    "hello from #{self.class.name}.port"
  end

end
