require_relative 'external_disk_writer'
require_relative 'external_saver'
require_relative 'external_storer'
require_relative 'image'
require_relative 'porter'

class Externals

  def porter
    @porter ||= Porter.new(self)
  end

  def disk
    @disk ||= ExternalDiskWriter.new
  end

  def saver
    @saver ||= ExternalSaver.new
  end

  def storer
    @storer ||= ExternalStorer.new
  end

  def image
    @image ||= Image.new(disk)
  end

end
