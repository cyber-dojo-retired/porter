require_relative 'external_disk_writer'
require_relative 'saver'
require_relative 'storer'
require_relative 'image'

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
