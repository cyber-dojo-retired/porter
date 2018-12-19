require_relative 'external_disk_writer'
require_relative 'external_saver'
require_relative 'external_storer'
require_relative 'external_env'
require_relative 'porter'

class Externals

  def porter
    @porter ||= Porter.new(self)
  end

  def saver
    @saver ||= ExternalSaver.new
  end

  def storer
    @storer ||= ExternalStorer.new
  end

  def env
    @env ||= ExternalEnv.new
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

end
