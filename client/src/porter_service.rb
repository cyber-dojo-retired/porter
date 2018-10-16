require_relative 'http_json_service'

class PorterService

  def sha
    get(__method__)
  end

  def port(kata_id)
    post(__method__, kata_id)
  end

  private

  include HttpJsonService

  def hostname
    'porter'
  end

  def port
    4517
  end

end
