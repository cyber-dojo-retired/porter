require_relative 'http_json_service'

class StorerService

  def m(arg)
    get(__method__, arg)
  end

  private

  include HttpJsonService

  def hostname
    'storer'
  end

  def port
    ?
  end

end
