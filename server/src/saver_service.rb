require_relative 'http_json_service'

class SaverService

  def m(arg)
    get(__method__, arg)
  end

  private

  include HttpJsonService

  def hostname
    'saver'
  end

  def port
    ?
  end

end
