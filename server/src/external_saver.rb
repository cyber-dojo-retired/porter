require_relative 'http_json_service'

class ExternalSaver

  def group_exists?(id)
    get(__method__, id)
  end

  def group_create(manifest)
    post(__method__, manifest)
  end

  def group_manifest(id)
    get(__method__, id)
  end

  private

  include HttpJsonService

  def hostname
    'saver'
  end

  def port
    4537
  end

end
