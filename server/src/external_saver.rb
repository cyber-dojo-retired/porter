require_relative 'http_json_service'

class ExternalSaver

  def m(arg)
    get(__method__, arg)
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
