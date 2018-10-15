require_relative 'http_json_service'

class ExternalStorer

  def m(arg)
    get(__method__, arg)
  end

  private

  include HttpJsonService

  def hostname
    'storer'
  end

  def port
    4577
  end

end
